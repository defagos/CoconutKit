//
//  HLSTaskOperation.m
//  Funds_iPad
//
//  Created by Samuel Défago on 12/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTaskOperation.h"

#import "HLSLogger.h"
#import "HLSRuntimeChecks.h"
#import "HLSTask+Friend.h"
#import "HLSTaskGroup+Friend.h"
#import "HLSTaskManager+Friend.h"

@interface HLSTaskOperation ()

@property (nonatomic, assign) HLSTaskManager *taskManager;
@property (nonatomic, assign) HLSTask *task;
@property (nonatomic, retain) NSThread *callingThread;

- (void)operationMain;

- (void)onCallingThreadPerformSelector:(SEL)selector object:(NSObject *)objectOrNil;
- (void)updateProgressToValue:(float)progress;
- (void)attachError:(NSError *)error;

- (void)notifyStart;
- (void)notifyRunningWithProgress:(NSNumber *)progress;
- (void)notifyEnd;
- (void)notifySettingReturnInfo:(NSDictionary *)returnInfo;
- (void)notifySettingError:(NSError *)error;

@end

@implementation HLSTaskOperation

#pragma mark -
#pragma mark Object creation and destruction

- (id)initWithTaskManager:(HLSTaskManager *)taskManager task:(HLSTask *)task
{
    if (self = [super init]) {
        self.taskManager = taskManager;
        self.task = task;
        self.callingThread = [NSThread currentThread];
    }
    return self;
}

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    self.taskManager = nil;
    self.task = nil;
    self.callingThread = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors and mutators

@synthesize taskManager = _taskManager;

@synthesize task = _task;

@synthesize callingThread = _callingThread;

#pragma mark -
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
    MISSING_METHOD_IMPLEMENTATION();
}

#pragma mark -
#pragma mark Executing code on the calling thread

- (void)onCallingThreadPerformSelector:(SEL)selector object:(NSObject *)objectOrNil
{
    [self performSelector:selector 
                 onThread:self.callingThread 
               withObject:objectOrNil
            waitUntilDone:NO];
}

// Remark: Originally, I intended to call this method "setProgress:", but this was a bad idea. It could have conflicted
//         with setProgress: methods defined by subclasses of HLSTaskOperation (and guess what, this just happened
//         since one of my subclasses implemented the ASIProgressDelegate protocol, which declares a setProgress: method)
- (void)updateProgressToValue:(float)progress
{
    [self onCallingThreadPerformSelector:@selector(notifyRunningWithProgress:) 
                                  object:[NSNumber numberWithFloat:progress]];
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

#pragma mark -
#pragma mark Code to be executed on the calling thread

- (void)notifyStart
{
    logger_debug(@"Task %@ starts", self.task);
    
    // Reset status
    [self.task reset];
    
    // If part of a non-running task group, first flag the task group as running and notify
    HLSTaskGroup *taskGroup = self.task.taskGroup;
    if (taskGroup && ! taskGroup.running) {
        logger_debug(@"Task group %@ starts", taskGroup);
        
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
    // Update and notify about the end of the task
    id<HLSTaskDelegate> taskDelegate = [self.taskManager delegateForTask:self.task];
    
    // Update the progress to 1.f on success, else do not alter current value (so that the progress value cannot go backwards)
    if (! self.task.error) {
        self.task.progress = 1.f;
        if ([taskDelegate respondsToSelector:@selector(taskProgressUpdated:)]) {
            [taskDelegate taskProgressUpdated:self.task];
        }
    }
    self.task.finished = YES;
    self.task.running = NO;
    
    if (! [self isCancelled]) {
        logger_debug(@"Task %@ ends successfully", self.task);
        if ([taskDelegate respondsToSelector:@selector(taskHasBeenProcessed:)]) {
            [taskDelegate taskHasBeenProcessed:self.task];
        }
    }
    else {
        logger_debug(@"Task %@ has been cancelled", self.task);
        if ([taskDelegate respondsToSelector:@selector(taskHasBeenCancelled:)]) {
            [taskDelegate taskHasBeenCancelled:self.task];
        }
    }
    
    // If part of a task group
    HLSTaskGroup *taskGroup = self.task.taskGroup;
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
                logger_debug(@"Task group %@ ends successfully", taskGroup);
                if ([taskGroupDelegate respondsToSelector:@selector(taskGroupHasBeenProcessed:)]) {
                    [taskGroupDelegate taskGroupHasBeenProcessed:taskGroup];
                }
            }
            else {
                logger_debug(@"Task group %@ has been cancelled", taskGroup);
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
