//
//  HLSTaskManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/18/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSTaskManager.h"

#import "HLSLogger.h"
#import "HLSTask+Friend.h"
#import "HLSTaskGroup+Friend.h"
#import "HLSTaskOperation.h"

@interface HLSTaskManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;                         // Manages the separate threads used for task processing
@property (nonatomic, strong) NSMutableSet *tasks;                                      // Keep a strong ref to task groups so that they stay alive
@property (nonatomic, strong) NSMutableSet *taskGroups;                                 // Keep a strong ref to task groups so that they stay alive
@property (nonatomic, strong) NSMutableDictionary *taskToOperationMap;                  // Maps a task to the associated HLSTaskOperation object
@property (nonatomic, strong) NSMutableDictionary *taskToDelegateMap;                   // Maps a task to the associated id<HLSTaskDelegate> object
@property (nonatomic, strong) NSMutableDictionary *delegateToTasksMap;                  // Maps some object id to the NSMutableSet of all HLSTask objects it is the delegate of
@property (nonatomic, strong) NSMutableDictionary *taskGroupToDelegateMap;              // Maps a task group to the associated id<HLSTaskGroupDelegate> object
@property (nonatomic, strong) NSMutableDictionary *delegateToTaskGroupsMap;             // Maps some object id to the NSMutableSet of all HLSTaskGroup objects it is the delegate of

@end

@implementation HLSTaskManager

#pragma mark Class methods

+ (instancetype)defaultManager
{
    static HLSTaskManager *s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[[self class] alloc] init];
    });
    return s_instance;
}

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self setMaxConcurrentTaskCount:4];
        [self.operationQueue setMaxConcurrentOperationCount:4];
        self.tasks = [NSMutableSet set];
        self.taskGroups = [NSMutableSet set];
        self.taskToOperationMap = [NSMutableDictionary dictionary];
        self.taskToDelegateMap = [NSMutableDictionary dictionary];
        self.delegateToTasksMap =[NSMutableDictionary dictionary];
        self.taskGroupToDelegateMap = [NSMutableDictionary dictionary];
        self.delegateToTaskGroupsMap = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark Accessors and mutators

- (void)setMaxConcurrentTaskCount:(NSInteger)count
{
    // Remark: It seems that with the recommended setting NSOperationQueueDefaultMaxConcurrentOperationCount (which
    //         lets the OS decide dynamically how many threads are needed), dependencies betweeen NSOperation objects
    //         are not applied anymore (bug?). Anyway, this does not work correctly, so we fix the number of threads
    //         to a seemingly good value
    if (count == NSOperationQueueDefaultMaxConcurrentOperationCount) {
        HLSLoggerWarn(@"Dynamic number of concurrent tasks is currently not working correctly; task count not changed");
    }
    else if (count > 1) {
        [self.operationQueue setMaxConcurrentOperationCount:count];
    }
    else {
        HLSLoggerError(@"Invalid number of concurrent tasks; task count not changed");
    }
}

#pragma mark Submitting tasks

- (void)submitTask:(HLSTask *)task
{
    // Cannot submit a task if already running
    if ([self.tasks containsObject:task]) {
        HLSLoggerWarn(@"Cannot submit a task which is already running");
        return;
    }
    
    // Get the corresponding operations
    NSSet *operations = [self operationsForTasks:[NSSet setWithObject:task]];
    
    // Register and schedule all operations
    for (HLSTaskOperation *operation in operations) {
        [self registerOperation:operation];
        [self.operationQueue addOperation:operation];
    }
}

- (void)submitTaskGroup:(HLSTaskGroup *)taskGroup
{
    // Cannot submit a task if already running
    if ([self.taskGroups containsObject:taskGroup]) {
        HLSLoggerWarn(@"Cannot submit a task group which is already running");
        return;
    }
    
    // Reset status
    [taskGroup reset];
    
    // If no operation in the task group, we are already done; update the status accordingly and simulate events
    if ([[taskGroup tasks] count] == 0) {
        id<HLSTaskGroupDelegate> taskGroupDelegate = [self delegateForTaskGroup:taskGroup];
        if (taskGroupDelegate) {
            if ([taskGroupDelegate respondsToSelector:@selector(taskGroupHasStartedProcessing:)]) {
                [taskGroupDelegate taskGroupHasStartedProcessing:taskGroup];
            }
            
            if ([taskGroupDelegate respondsToSelector:@selector(taskGroupHasBeenProcessed:)]) {
                [taskGroupDelegate taskGroupHasBeenProcessed:taskGroup];
            }            
        }
        
        taskGroup.finished = YES;
        return;
    }    
    
    // Get the corresponding operations
    NSSet *operations = [self operationsForTasks:[taskGroup tasks]];
    
    // Register all operations
    for (HLSTaskOperation *operation in operations) {
        [self registerOperation:operation];
    }
    
    // Apply task group dependencies
    for (HLSTask *task in [taskGroup tasks]) {
        // Get dependencies if any
        NSSet *dependencyTasks = [taskGroup dependenciesForTask:task];
        if ([dependencyTasks count] == 0) {
            continue;
        }
        
        // Retrieve the corresponding operation
        NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
        HLSTaskOperation *operation = [self.taskToOperationMap objectForKey:taskKey];
        
        // Set dependencies
        for (HLSTask *dependencyTask in dependencyTasks) {
            // Get the dependency operation
            NSValue *dependencyTaskKey = [NSValue valueWithNonretainedObject:dependencyTask];
            HLSTaskOperation *dependencyOperation = [self.taskToOperationMap objectForKey:dependencyTaskKey];
            if (! dependencyOperation) {
                continue;
            }
            
            // Create the dependency between operations
            [operation addDependency:dependencyOperation];
        }
    }
    
    // Register object relationships
    [self registerTaskGroup:taskGroup];
    
    // Schedule all operations
    for (HLSTaskOperation *operation in operations) {
        [self.operationQueue addOperation:operation];
    }
}

#pragma mark Cancelling tasks

- (void)cancelTask:(HLSTask *)task
{
    // If already finished (cancelled or complete), nothing to cancel
    if (task.finished) {
        HLSLoggerDebug(@"Task %@ is already complete or cancelled", task);
        return;
    }
    
    // Locate the associated operation
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    HLSTaskOperation *operation = [self.taskToOperationMap objectForKey:taskKey];
    if (! operation) {
        return;
    }
    
    // Flag the operation as cancelled
    task.cancelled = YES;
    
    // When cancelling tasks, all those which have been started will update their status when they gracefully
    // stop (and unregister them at this point). For tasks which have not been started, this has to be done
    // here
    if (! [operation isExecuting]) {
        // If part of a task group, first cancel all dependent tasks; a task group is removed once all tasks it contains are
        // marked as finished. Here we are careful enough to cancel all dependent task before the current task is set as 
        // finished. This way the task group is guaranteed to survive the loop below
        HLSTaskGroup *taskGroup = task.taskGroup;
        if (taskGroup) {
            // Cancel all tasks strongly depending on the task
            NSSet *strongDependents = [taskGroup strongDependentsForTask:task];
            for (HLSTask *dependent in strongDependents) {
                [self cancelTask:dependent];
            }
        }
        
        task.finished = YES;
        
        // Notify the task delegate
        id<HLSTaskDelegate> taskDelegate = [self delegateForTask:task];
        if ([taskDelegate respondsToSelector:@selector(taskHasBeenCancelled:)]) {
            [taskDelegate taskHasBeenCancelled:task];
        }
        
        if (taskGroup) {            
            [taskGroup updateStatus];
            
            // If the task group is now complete, update and notify as well
            if (taskGroup.finished) {
                taskGroup.running = NO;
                
                id<HLSTaskGroupDelegate> taskGroupDelegate = [self delegateForTaskGroup:taskGroup];
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
        
        [self unregisterOperation:operation];
    }
    
    [operation cancel];
}

- (void)cancelTaskGroup:(HLSTaskGroup *)taskGroup
{
    taskGroup.cancelled = YES;
    
    // Cancel all individual tasks
    for (HLSTask *task in [taskGroup tasks]) {
        [self cancelTask:task];
    }
}

- (void)cancelTasksWithTag:(NSString *)tag
{
    NSArray *tasks = [self tasksWithTag:tag];
    for (HLSTask *task in tasks) {
        [self cancelTask:task];
    }
}

- (void)cancelTaskGroupsWithTag:(NSString *)tag
{
    NSArray *taskGroups = [self taskGroupsWithTag:tag];
    for (HLSTaskGroup *taskGroup in taskGroups) {
        [self cancelTaskGroup:taskGroup];
    }
}

- (void)cancelTasksWithDelegate:(id)delegate
{
    // Cancel all task groups associated with this delegate
    NSValue *delegateKey = [NSValue valueWithNonretainedObject:delegate];
    NSSet *taskGroupsForDelegate = [NSSet setWithSet:[self.delegateToTaskGroupsMap objectForKey:delegateKey]];
    for (HLSTaskGroup *taskGroup in taskGroupsForDelegate) {
        [self cancelTaskGroup:taskGroup];
    }
    
    // Cancel all single tasks associated with this delegate
    NSSet *tasksForDelegate = [NSSet setWithSet:[self.delegateToTasksMap objectForKey:delegateKey]];
    for (HLSTask *task in tasksForDelegate) {
        [self cancelTask:task];
    }
}

#pragma mark Finding tasks

- (NSArray *)tasksWithTag:(NSString *)tag
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag MATCHES %@", tag];
    return [[self.tasks filteredSetUsingPredicate:predicate] allObjects];
}

- (NSArray *)taskGroupsWithTag:(NSString *)tag
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag MATCHES %@", tag];
    return [[self.taskGroups filteredSetUsingPredicate:predicate] allObjects];    
}

#pragma mark Registering and unregistering task delegates

- (void)registerDelegate:(id<HLSTaskDelegate>)delegate forTask:(HLSTask *)task
{
    // Unregister any previously registered delegate first
    [self unregisterDelegateForTask:task];
    
    // Register the task - delegate relationship; use the task pointer as key
    // TODO: I first expected the obvious following code to work:
    //          NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    //          [self.taskToDelegateMap setObject:delegate forKey:taskKey];
    //       but some strange crashes occurred under some circumstances (most notably when the manager
    //       object was fed with many tasks while many other tasks were still being processed; in my
    //       case web service requests were being sent fast with a slow internet connection). After
    //       investigation the dictionary taskToDelegateMap is in some cases corrupt, but the
    //       reason is unclear since:
    //         - all processing occurs on the calling thread, no thread interleaving issues come into play
    //         - I was careful enough to iterate on copies of data structures when a loop body can potentially
    //           alter it, so no enumerator invalidation issues should occur
    //       I could not find the reason why this problem occurs, but I found a solution: copy & swap. 
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    NSMutableDictionary *tempTaskToDelegateMap = [NSMutableDictionary dictionaryWithDictionary:self.taskToDelegateMap];
    [tempTaskToDelegateMap setObject:delegate forKey:taskKey];
    self.taskToDelegateMap = tempTaskToDelegateMap;
    
    // Register the inverse delegate - task relationship; use the delegate pointer as key
    NSValue *delegateKey = [NSValue valueWithNonretainedObject:delegate];
    NSMutableSet *tasksForDelegate = [self.delegateToTasksMap objectForKey:delegateKey];
    // Create the set lazily if it does not exist
    if (! tasksForDelegate) {
        tasksForDelegate = [NSMutableSet set];
        [self.delegateToTasksMap setObject:tasksForDelegate forKey:delegateKey];
    }
    [tasksForDelegate addObject:task];
}

- (void)registerDelegate:(id<HLSTaskGroupDelegate>)delegate forTaskGroup:(HLSTaskGroup *)taskGroup
{
    // Unregister any previously registered delegate first
    [self unregisterDelegateForTaskGroup:taskGroup];
    
    // Register the task group - delegate relationship; use the task pointer as key
    NSValue *taskGroupKey = [NSValue valueWithNonretainedObject:taskGroup];
    [self.taskGroupToDelegateMap setObject:delegate forKey:taskGroupKey];
    
    // Register the inverse delegate - task group relationship; use the delgate pointer as key
    NSValue *delegateKey = [NSValue valueWithNonretainedObject:delegate];
    NSMutableSet *taskGroupsForDelegate = [self.delegateToTaskGroupsMap objectForKey:delegateKey];
    // Create the set lazily if it does not exist
    if (! taskGroupsForDelegate) {
        taskGroupsForDelegate = [NSMutableSet set];
        [self.delegateToTaskGroupsMap setObject:taskGroupsForDelegate forKey:delegateKey];
    }
    [taskGroupsForDelegate addObject:taskGroup]; 
}

- (void)unregisterDelegateForTask:(HLSTask *)task
{
    // Find if a delegate has been defined for this task; use the task pointer as key
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    id<HLSTaskDelegate> delegate = [self.taskToDelegateMap objectForKey:taskKey];
    if (! delegate) {
        return;
    }
    
    // Remove the task - delegate relationship
    // TODO: Copy & swap strategy to avoid strange dictionary corruption; see registerDelegate:. Normally the following
    //       should have worked:
    //           [self.taskToDelegateMap removeObjectForKey:taskKey];
    NSMutableDictionary *tempTaskToDelegateMap = [NSMutableDictionary dictionaryWithDictionary:self.taskToDelegateMap];
    [tempTaskToDelegateMap removeObjectForKey:taskKey];
    self.taskToDelegateMap = tempTaskToDelegateMap;
    
    // Remove the inverse delegate - task relationship; use the delegate pointer as key
    NSValue *delegateKey = [NSValue valueWithNonretainedObject:delegate];
    NSMutableSet *tasksForDelegate = [self.delegateToTasksMap objectForKey:delegateKey];
    [tasksForDelegate removeObject:task];
    
    // If the set is now empty for this delegate, then remove the dictionary entry as well
    if ([tasksForDelegate count] == 0) {
        [self.delegateToTasksMap removeObjectForKey:delegateKey];
    }
}

- (void)unregisterDelegateForTaskGroup:(HLSTaskGroup *)taskGroup
{
    // Find if a delegate has been defined for this task group; use the task pointer as key
    NSValue *taskGroupKey = [NSValue valueWithNonretainedObject:taskGroup];
    id<HLSTaskGroupDelegate> delegate = [self.taskGroupToDelegateMap objectForKey:taskGroupKey];
    if (! delegate) {
        return;
    }
    
    // Remove the task group - delegate relationship
    [self.taskGroupToDelegateMap removeObjectForKey:taskGroupKey];
    
    // Remove the inverse delegate - task group relationship
    NSValue *delegateKey = [NSValue valueWithNonretainedObject:delegate];
    NSMutableSet *taskGroupsForDelegate = [self.delegateToTaskGroupsMap objectForKey:delegateKey];
    [taskGroupsForDelegate removeObject:taskGroup];
    
    // If the set is now empty for this delegate, then remove the dictionary entry as well
    if ([taskGroupsForDelegate count] == 0) {
        [self.delegateToTaskGroupsMap removeObjectForKey:delegateKey];
    }
}

- (void)unregisterDelegateAndCancelAssociatedTasks:(id)delegate
{
    // Cancel tasks first (had we unregistered first, we would have lost track of the delegate - task 
    // relationships, cancelling nothing!) 
    [self cancelTasksWithDelegate:delegate];
    [self unregisterDelegate:delegate];
}

- (void)unregisterDelegate:(id)delegate
{
    // Find all tasks for this delegate, and unregister; use the delegate pointer as key
    NSValue *delegateKey = [NSValue valueWithNonretainedObject:delegate];
    NSSet *tasksForDelegate = [NSSet setWithSet:[self.delegateToTasksMap objectForKey:delegateKey]];
    for (HLSTask *task in tasksForDelegate) {
        [self unregisterDelegateForTask:task];
    }
    
    // Same for task groups
    NSSet *taskGroupsForDelegate = [NSSet setWithSet:[self.delegateToTaskGroupsMap objectForKey:delegateKey]];
    for (HLSTaskGroup *taskGroup in taskGroupsForDelegate) {
        [self unregisterDelegateForTaskGroup:taskGroup];
    }
}

#pragma mark Instantiating operations for a set of tasks

- (NSSet *)operationsForTasks:(NSSet *)tasks
{
    NSMutableSet *operations = [NSMutableSet set];
    for (HLSTask *task in tasks) {
        Class operationClass = [task operationClass];
        NSAssert([operationClass isSubclassOfClass:[HLSTaskOperation class]], @"Class %@ is not a subclass of HLSTaskOperation", operationClass);
        HLSTaskOperation *operation = [[operationClass alloc] initWithTaskManager:self task:task];
        [operations addObject:operation];
    }
    return operations;
}

#pragma mark Registering object relationships

- (void)registerOperation:(HLSTaskOperation *)operation
{
    // Keep a strong reference to the operation
    [self.tasks addObject:operation.task];
    
    // Save the relationship between task and operation; use the task pointer as key
    NSValue *taskKey = [NSValue valueWithNonretainedObject:operation.task];
    [self.taskToOperationMap setObject:operation forKey:taskKey];
}

- (void)unregisterOperation:(HLSTaskOperation *)operation
{
    // Unregister the associated task - operation relationship; use the task pointer as key
    NSValue *taskKey = [NSValue valueWithNonretainedObject:operation.task];
    [self.taskToOperationMap removeObjectForKey:taskKey];   
    
    // Automatically cleanup delegate registrations
    [self unregisterDelegateForTask:operation.task];
    
    // If the task is part of a task group, unregister it if all task group operations are complete
    HLSTaskGroup *taskGroup = operation.task.taskGroup;
    if (taskGroup) {
        if (taskGroup.finished) {
            [self unregisterTaskGroup:taskGroup];
        }        
    }
    
    // Finally, release the strong ref to the task
    [self.tasks removeObject:operation.task];
}

- (void)registerTaskGroup:(HLSTaskGroup *)taskGroup
{
    // Keep a strong ref to the task group
    [self.taskGroups addObject:taskGroup];
}

- (void)unregisterTaskGroup:(HLSTaskGroup *)taskGroup
{
    // Automatically cleanup delegate registrations
    [self unregisterDelegateForTaskGroup:taskGroup];
    
    // Release the strong ref to the task group
    [self.taskGroups removeObject:taskGroup];
}

#pragma mark Retrieving registered delegates

- (id<HLSTaskDelegate>)delegateForTask:(HLSTask *)task
{
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    return [self.taskToDelegateMap objectForKey:taskKey];
}

- (id<HLSTaskGroupDelegate>)delegateForTaskGroup:(HLSTaskGroup *)taskGroup
{
    NSValue *taskGroupKey = [NSValue valueWithNonretainedObject:taskGroup];
    return [self.taskGroupToDelegateMap objectForKey:taskGroupKey];
}

@end
