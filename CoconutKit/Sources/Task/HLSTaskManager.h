//
//  HLSTaskManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTask.h"
#import "HLSTaskGroup.h"
                
/**
 * Concrete class responsible for instantiating, processing and managing HLSTaskOperation objects spawned for each
 * task submitted to it. Each such object represents a work unit processed by a dedicated thread.
 *
 * A delegation mechanism is used to notify clients about the task processing status. Objects register themselves
 * to get notified about a task status. Note that a delegate registration is removed automatically when the 
 * associated task processing ends. This means that when you are re-submitting a task you will need to register
 * a delegate even if one was already registered for this task.
 *
 * As always with delegation in asynchronous contexts, it is especially important that delegates do not forget to
 * unregister themselves before they get destroyed, otherwise crashes are likely to occur if operations are still
 * running when their delegate dies. To avoid such issues, never forget to call unregisterDelegateAndCancelAssociatedTasks:
 * or unregisterDelegate in the dealloc method of your delegates. This will unregister the delegate, ensuring that
 * it cannot be notified anymore when it gets destroyed.
 *
 * This object is not thread-safe. All operations on it must stem from the same thread, otherwise the behavior is 
 * undefined.
 *
 * Designated initializer: init
 */
@interface HLSTaskManager : NSObject {
@private
    NSOperationQueue *_operationQueue;                   // Manages the separate threads used for task processing
    NSMutableSet *_tasks;                                // Keep a strong ref to task groups so that they stay alive
    NSMutableSet *_taskGroups;                           // Keep a strong ref to task groups so that they stay alive
    NSMutableDictionary *_taskToOperationMap;            // Maps a task to the associated HLSTaskOperation object
    NSMutableDictionary *_taskToDelegateMap;             // Maps a task to the associated id<HLSTaskDelegate> object
    NSMutableDictionary *_delegateToTasksMap;            // Maps some object id to the NSMutableSet of all HLSTask objects it is the delegate of
    NSMutableDictionary *_taskGroupToDelegateMap;        // Maps a task group to the associated id<HLSTaskGroupDelegate> object
    NSMutableDictionary *_delegateToTaskGroupsMap;       // Maps some object id to the NSMutableSet of all HLSTaskGroup objects it is the delegate of
}

/**
 * Returns the default singleton instance. In general this instance should suffice. If you need more task manager
 * instances (in a multi-threaded code, you might e.g. want to assign separate managers to separate threads), you can 
 * create those manually.
 */
+ (HLSTaskManager *)defaultManager;

/**
 * Change the number of tasks processed simultaneously. Default is 4. This setting does not affect already running
 * operations
 */
- (void)setMaxConcurrentTaskCount:(NSInteger)count;

/**
 * Submit a single task; if you have several tasks to process, consider bundling them as a task group, and use
 * submitTaskGroup: instead
 */
- (void)submitTask:(HLSTask *)task;

/**
 * Submit a task group
 */
- (void)submitTaskGroup:(HLSTaskGroup *)taskGroup;

/**
 * Cancel a single task
 */
- (void)cancelTask:(HLSTask *)task;

/**
 * Cancel a task group
 */
- (void)cancelTaskGroup:(HLSTaskGroup *)taskGroup;

/**
 * Cancel tasks by tag. Several tasks may share the same tag, in which case they will all be cancellled 
 */
- (void)cancelTasksWithTag:(NSString *)tag;

/**
 * Cancel task groups by tag. Several tasks may share the same tag, in which case they will all be cancelled
 */
- (void)cancelTaskGroupsWithTag:(NSString *)tag;

/**
 * Cancel all tasks and task groups which have some object as delegate. This method can be called when you
 * want to cancel all tasks associated with a delegate, while letting the delegate receive notification about
 * the end of the process. This requires you to guarantee that the delegate will be still alive when the tasks 
 * end, otherwise crashes will occur when dead delegates get notified. This method is for example useful for cancelling
 * tasks when the view associated to a view controller disappears (but does not get deallocated).
 *
 * If you are not interested in end process notifications, call the safer unregisterDelegateAndCancelAssociatedTasks:
 * method instead
 */
- (void)cancelTasksWithDelegate:(id)delegate;

/**
 * Return an NSArray of running or pending HLSTask objects bearing the specified tag (already completed tasks are not
 * returned). If no match is found, this method returns an empty array
 */
- (NSArray *)tasksWithTag:(NSString *)tag;

/**
 * Return an NSArray of running or pending HLSTaskGroup objects bearing the specified tag (already completed tasks are not
 * returned). If no match is found, this method returns an empty array
 */
- (NSArray *)taskGroupsWithTag:(NSString *)tag;

/**
 * Register delegates for tasks. Only one delegate can be registered. If another delegate registers itself,
 * any existing registration is removed first 
 */
- (void)registerDelegate:(id<HLSTaskDelegate>)delegate forTask:(HLSTask *)task;
- (void)registerDelegate:(id<HLSTaskGroupDelegate>)delegate forTaskGroup:(HLSTaskGroup *)taskGroup;

/**
 * Unregister the delegate associated with a specific task
 */
- (void)unregisterDelegateForTask:(HLSTask *)task;
- (void)unregisterDelegateForTaskGroup:(HLSTaskGroup *)taskGroup;

/**
 * Unregister a delegate and cancel all tasks it is the delegate of. Calling this method in an object dealloc
 * method is the safest and easiest way to cancel all tasks it was the delegate of
 */
- (void)unregisterDelegateAndCancelAssociatedTasks:(id)delegate;

/**
 * Unregister a delegate while letting all tasks it is the delegate of run. Calling this method in an object
 * delloc method is the safest and easiest way to let tasks still run, even after the object receiving the
 * associated events has died
 */
- (void)unregisterDelegate:(id)delegate;

@end
