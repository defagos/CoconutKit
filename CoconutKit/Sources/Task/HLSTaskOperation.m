//
//  HLSTaskOperation.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/18/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSTaskOperation.h"

#import "HLSLogger.h"
#import "HLSTask+Friend.h"
#import "HLSTaskGroup+Friend.h"
#import "HLSTaskManager+Friend.h"

@interface HLSTaskOperation ()

@property (nonatomic, weak) HLSTaskManager *taskManager;          // The task manager which spawned the operation
@property (nonatomic, weak) HLSTask *task;                        // The task the operation is processing
@property (nonatomic, strong) NSThread *callingThread;              // Thread onto which spawned the operation

@end

@implementation HLSTaskOperation

#pragma mark Object creation and destruction

- (instancetype)initWithTaskManager:(HLSTaskManager *)taskManager task:(HLSTask *)task
{
    if (self = [super init]) {
        self.taskManager = taskManager;
        self.task = task;
        self.callingThread = [NSThread currentThread];
    }
    return self;
}

#pragma mark Thread main function

- (void)main
{
    // Notify begin
    [self onCallingThreadPerformSelector:@selector(notifyStart) object:nil];
    
    // Execute the main method code
    [self operationMain];
    
    // Notify end
    [self onCallingThreadPerformSelector:@selector(notifyEnd) object:nil];
}

- (void)operationMain
{
    HLSMissingMethodImplementation();
}

#pragma mark Executing code on the calling thread

- (void)onCallingThreadPerformSelector:(SEL)selector object:(NSObject *)objectOrNil
{
    // HUGE WARNING here! If we do not wait until done, we might sometimes (most notably under heavy load) perform selectors
    // on the calling thread, but not in the order they were scheduled. This can be a complete disaster if we perform the
    // notifyEnd method before a progress update via notifyRunningWithProgress:. If waitUntilDone is left to NO, then this
    // might happen and, since the task is released by notifyEnd, any notifyRunningWithProgress: coming after it would crash.
    // To avoid this issue, waitUntilDone must clearly be set to YES.
    // Remark: This equivalently means that when waitUntilDone is NO, selectors are not necessarily processed in the order they 
    //         are "sent" to the calling thread. Most of the time they seem to, but not always. Setting waitUntilDone to YES 
    //         guarantees they will be processed sequentially (of course, since performSelector blocks the thread). IMHO, I would 
    //         have not called this method performSelector:onThread:withObject:waitUntilDone:, 
    [self performSelector:selector 
                 onThread:self.callingThread 
               withObject:objectOrNil
            waitUntilDone:YES];
}

// Remark: Originally, I intended to call this method "setProgress:", but this was a bad idea. It could have conflicted
//         with setProgress: methods defined by subclasses of HLSTaskOperation (and guess what, this just happened
//         since one of my subclasses implemented the ASIProgressDelegate protocol, which declares a setProgress: method)
- (void)updateProgressToValue:(float)progress
{
    [self onCallingThreadPerformSelector:@selector(notifyRunningWithProgress:) 
                                  object:@(progress)];
}

- (void)attachReturnInfo:(NSDictionary *)returnInfo
{
    [self onCallingThreadPerformSelector:@selector(notifySettingReturnInfo:) 
                                  object:returnInfo];
}

- (void)attachError:(NSError *)error
{
    [self onCallingThreadPerformSelector:@selector(notifySettingError:) 
                                  object:error];
}

#pragma mark Code to be executed on the calling thread

- (void)notifyStart
{
    HLSLoggerDebug(@"Task %@ starts", self.task);
    
    // Reset status
    [self.task reset];
    
    // If part of a non-running task group, first flag the task group as running and notify
    HLSTaskGroup *taskGroup = self.task.taskGroup;
    if (taskGroup && ! taskGroup.running) {
        HLSLoggerDebug(@"Task group %@ starts", taskGroup);
        
        taskGroup.running = YES;
        id<HLSTaskGroupDelegate> taskGroupDelegate = [self.taskManager delegateForTaskGroup:taskGroup];
        if ([taskGroupDelegate respondsToSelector:@selector(taskGroupHasStartedProcessing:)]) {
            [taskGroupDelegate taskGroupHasStartedProcessing:taskGroup];
        }
    }
    
    // ... then flag the task as running and notify ...
    id<HLSTaskDelegate> taskDelegate = [self.taskManager delegateForTask:self.task];
    self.task.running = YES;
    if ([taskDelegate respondsToSelector:@selector(taskHasStartedProcessing:)]) {
        [taskDelegate taskHasStartedProcessing:self.task];
    }
    self.task.progress = 0.f;
    if ([taskDelegate respondsToSelector:@selector(taskProgressUpdated:)]) {
        [taskDelegate taskProgressUpdated:self.task];
    }
    
    // ... and finally update and notify about the task group status
    if (taskGroup) {
        [taskGroup updateStatus];
        id<HLSTaskGroupDelegate> taskGroupDelegate = [self.taskManager delegateForTaskGroup:taskGroup];
        if ([taskGroupDelegate respondsToSelector:@selector(taskGroupProgressUpdated:)]) {
            [taskGroupDelegate taskGroupProgressUpdated:taskGroup];
        }
    }
}

- (void)notifyRunningWithProgress:(NSNumber *)progress
{
    // Update and notify about the task progress
    self.task.progress = [progress floatValue];
    id<HLSTaskDelegate> taskDelegate = [self.taskManager delegateForTask:self.task];
    if ([taskDelegate respondsToSelector:@selector(taskProgressUpdated:)]) {
        [taskDelegate taskProgressUpdated:self.task];
    }
    
    // If part of a task group, update and notify about its status as well
    HLSTaskGroup *taskGroup = self.task.taskGroup;
    if (taskGroup) {
        [taskGroup updateStatus];
        id<HLSTaskGroupDelegate> taskGroupDelegate = [self.taskManager delegateForTaskGroup:taskGroup];
        if ([taskGroupDelegate respondsToSelector:@selector(taskGroupProgressUpdated:)]) {
            [taskGroupDelegate taskGroupProgressUpdated:taskGroup];
        }
    }
}

- (void)notifyEnd
{
    id<HLSTaskDelegate> taskDelegate = [self.taskManager delegateForTask:self.task];
    
    // If part of a task group, first cancel all dependent tasks; a task group is removed once all tasks it contains are
    // marked as finished. Here we are careful enough to cancel all dependent task before the current task is set as 
    // finished. This way the task group is guaranteed to survive the loop below
    HLSTaskGroup *taskGroup = self.task.taskGroup;
    if (taskGroup) {
        // Cancel all tasks strongly depending on the task it not successful
        if ([self isCancelled] || self.task.error) {
            NSSet *strongDependents = [taskGroup strongDependentsForTask:self.task];
            for (HLSTask *dependent in strongDependents) {
                [self.taskManager cancelTask:dependent];
            }
        }
    }
    
    // Update the progress to 1.f on success, else do not alter current value (so that the progress value cannot go backwards)
    if (! self.task.error && ! [self isCancelled]) {
        self.task.progress = 1.f;
        if ([taskDelegate respondsToSelector:@selector(taskProgressUpdated:)]) {
            [taskDelegate taskProgressUpdated:self.task];
        }
    }
    self.task.finished = YES;
    self.task.running = NO;
    
    // The task has been cancelled
    if ([self isCancelled]) {
        HLSLoggerDebug(@"Task %@ has been cancelled", self.task);
        if ([taskDelegate respondsToSelector:@selector(taskHasBeenCancelled:)]) {
            [taskDelegate taskHasBeenCancelled:self.task];
        }        
    }
    // The task has been processed
    else {
        // Successful
        if (! self.task.error) {
            HLSLoggerDebug(@"Task %@ ends successfully", self.task);
        }
        // An error has been attached during processing
        else {
            HLSLoggerDebug(@"Task %@ has encountered an error", self.task);
        }
        
        if ([taskDelegate respondsToSelector:@selector(taskHasBeenProcessed:)]) {
            [taskDelegate taskHasBeenProcessed:self.task];
        }        
    }
    
    // If part of a task group
    if (taskGroup) {
        // Update an notify about the task group progress as well
        id<HLSTaskGroupDelegate> taskGroupDelegate = [self.taskManager delegateForTaskGroup:taskGroup];
        [taskGroup updateStatus];
        if ([taskGroupDelegate respondsToSelector:@selector(taskGroupProgressUpdated:)]) {
            [taskGroupDelegate taskGroupProgressUpdated:taskGroup];
        }
        
        // If the task group is now complete, update and notify as well
        if (taskGroup.finished) {
            taskGroup.running = NO;
            
            if (! taskGroup.cancelled) {
                HLSLoggerDebug(@"Task group %@ ends successfully", taskGroup);
                if ([taskGroupDelegate respondsToSelector:@selector(taskGroupHasBeenProcessed:)]) {
                    [taskGroupDelegate taskGroupHasBeenProcessed:taskGroup];
                }
            }
            else {
                HLSLoggerDebug(@"Task group %@ has been cancelled", taskGroup);
                if ([taskGroupDelegate respondsToSelector:@selector(taskGroupHasBeenCancelled:)]) {
                    [taskGroupDelegate taskGroupHasBeenCancelled:taskGroup];
                }
            }
        }
    }
    
    // Only the operation itself knows when it is done and can unregister itself from the manager it was
    // executed from
    [self.taskManager unregisterOperation:self];
}

- (void)notifySettingReturnInfo:(NSDictionary *)returnInfo
{
    self.task.returnInfo = returnInfo;
}

- (void)notifySettingError:(NSError *)error
{
    self.task.error = error;
}

@end
