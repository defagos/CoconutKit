//
//  HLSTaskGroup.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSTask.h"

#define kTaskGroupNoTimeIntervalEstimateAvailable                     -1.

// Forward declarations
@protocol HLSTaskGroupDelegate;

/**
 * This class is a container for task objects to be submitted simultaneously. Do not inherit from this class,
 * subclass HLSTask to implement your custom task logic, and use HLSTaskGroup for submitting many custom tasks
 * at once. This allows you to track not only the individual status of each task, but also the overall progress
 * of the task group. Moreover, dependencies between tasks can be set, which is impossible to achieve when
 * submitting single tasks.
 *
 * A task group must not be submitted several times simultaneously (this leads to undefined behavior). A task 
 * group which was fully processed can be submitted again (and with another delegate if needed), but must not be 
 * already running.
 */
@interface HLSTaskGroup : NSObject

/**
 * Create a task group
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * Optional tag to identify a task group
 */
@property (nonatomic, strong) NSString *tag;

/**
 * Dictionary which can be used freely to convey additional information
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 * Add a task to the task group
 */
- (void)addTask:(HLSTask *)task;

/**
 * Return the current set of HLSTask objects
 */
- (NSSet *)tasks;

/**
 * Return YES if the task group is being processed
 */
@property (nonatomic, readonly, assign, getter=isRunning) BOOL running;

/**
 * Return YES if the task group processing is done (i.e. all contained tasks are finished as well)
 */
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

/**
 * Return YES if the task group processing has been cancelled
 */
@property (nonatomic, readonly, assign, getter=isCancelled) BOOL cancelled;

/**
 * Overall progress value (between 0.f and 1.f). If some tasks fail this value may not reach 1.f
 */
@property (nonatomic, readonly, assign) float progress;

/**
 * Return an estimate about the remaining time before the task group processing completes (or kTaskGroupNoTimeIntervalEstimateAvailable if no
 * estimate is available yet)
 * Important remark: Accurate measurements can only be obtained if the progress update rate of a task group is not varying fast (in another
 *                   words: Constant over long enough periods of time). This is most likely to happen when all tasks are similar (i.e. the
 *                   underlying processing is similar) and roughly of the same size.
 * Not meant to be overridden
 */
@property (nonatomic, readonly, assign) NSTimeInterval remainingTimeIntervalEstimate;

/**
 * Return a localized string describing the estimated time before completion
 * Not meant to be overridden
 * (see remark of -remainingTimeIntervalEstimate method)
 */
- (NSString *)remainingTimeIntervalEstimateLocalizedString;

/**
 * Return the current number of failed tasks
 */
- (NSUInteger)nbrFailures;

/**
 * Create dependencies between tasks of a task group (both tasks must have already been added to the task group. If task1 depends on task2, then 
 * task1 will only begin processing once task2 has been fully processed. Moreover, if the strong boolean is set to YES, task1 will be
 * cancelled before it starts if task2 failed or was cancelled ("strong dependency"). Otherwise task1 will be started after task2 ends, no
 * matter what happened with task2 ("weak dependency")
 */
- (void)addDependencyForTask:(HLSTask *)task1 onTask:(HLSTask *)task2 strong:(BOOL)strong;

@end

@protocol HLSTaskGroupDelegate <NSObject>
@optional

/**
 * The task group has started
 */
- (void)taskGroupHasStartedProcessing:(HLSTaskGroup *)taskGroup;

/**
 * The task group is being processed and has an updated status (you can e.g. call progress to get its completion
 * status)
 */
- (void)taskGroupProgressUpdated:(HLSTaskGroup *)taskGroup;

/**
 * The task group has been fully processed. You can check the number of failures or loop over all tasks to get their
 * status or errors individually
 */
- (void)taskGroupHasBeenProcessed:(HLSTaskGroup *)taskGroup;

/**
 * The task group has been cancelled
 */
- (void)taskGroupHasBeenCancelled:(HLSTaskGroup *)taskGroup;

@end

