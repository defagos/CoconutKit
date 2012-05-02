//
//  HLSTaskGroup.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSProgressTracker.h"
#import "HLSTask.h"

// Forward declarations
@protocol HLSTaskGroupDelegate;

/**
 * This class is a container for task objects to be submitted simultaneously. Do not inherit from this class,
 * subclass HLSTask to implement your custom task logic, and use HLSTaskGroup for submitting many custom tasks
 * at once. This allows you to track not only the individual status of each task, but also the overall progress
 * of the task group. Moreover, dependencies between tasks can be set, which is impossible to achieve when
 * submitting individual tasks.
 *
 * A task group must not be submitted several times simultaneously (this leads to undefined behavior). A task 
 * group which was fully processed can be submitted again (and with another delegate if needed), but must not be 
 * already running.
 *
 * Designated initializer: init:
 */
@interface HLSTaskGroup : NSObject {
@private
    NSString *_tag;
    NSDictionary *_userInfo;
    NSMutableSet *_taskSet;                                     // contains HLSTask objects
    // Dependencies between tasks are saved in both directions for faster lookup
    NSMutableDictionary *_weakTaskDependencyMap;                // maps an HLSTask object to the NSMutableSet of all other HLSTask objects it weakly depends on
    NSMutableDictionary *_strongTaskDependencyMap;              // maps an HLSTask object to the NSMutableSet of all other HLSTask objects it strongly depends on
    NSMutableDictionary *_taskToWeakDependentsMap;              // maps an HLSTask object to the NSMutableSet of all HLSTask objects weakly depending on it
    NSMutableDictionary *_taskToStrongDependentsMap;            // maps an HLSTask object to the NSMutableSet of all HLSTask objects strongly depending on it
    BOOL _running;
    BOOL _finished;
    BOOL _cancelled;
    HLSProgressTracker *_progressTracker;
    NSUInteger _numberOfFailures;
}

/**
 * Optional tag to identify a task group
 */
@property (nonatomic, retain) NSString *tag;

/**
 * Dictionary which can be used freely to convey additional information
 */
@property (nonatomic, retain) NSDictionary *userInfo;

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
 * Task progress information. The progress value always reaches 1.f when all tasks have ended (whether they
 * finished successfully, encountered an error, or have been cancelled)
 *
 * Not meant to be overridden
 */
- (id<HLSProgressTrackerInfo>)progressTrackerInfo;

/**
 * Return the current number of failed tasks
 */
- (NSUInteger)numberOfFailures;

/**
 * Create dependencies between tasks of a task group (both tasks must have already been added to the task 
 * group. If task1 depends on task2, then task1 will only begin processing once task2 has been fully processed. 
 * Moreover, if the strong boolean is set to YES, task1 will be cancelled before it starts if task2 failed or 
 * was cancelled ("strong dependency"). Otherwise task1 will be started after task2 ends, no
 * matter what happened with task2 ("weak dependency")
 */
- (void)addDependencyForTask:(HLSTask *)task1 onTask:(HLSTask *)task2 strong:(BOOL)strong;

@end

@protocol HLSTaskGroupDelegate <NSObject>
@optional

/**
 * The task group has started
 */
- (void)taskGroupDidStart:(HLSTaskGroup *)taskGroup;

/**
 * The task group is being processed and has an updated status (you can e.g. call progress to get its 
 * completion status)
 */
- (void)taskGroupDidProgress:(HLSTaskGroup *)taskGroup;

/**
 * The task group has been fully processed. You can check the number of failures or loop over all tasks 
 * to get their status or errors 
 * individually
 */
- (void)taskGroupDidFinish:(HLSTaskGroup *)taskGroup;

/**
 * The task group has been cancelled. Usually you wouldn't expect the need for delegate method to be 
 * called when a cancel request occurs, because cancel operations usually executed on the spot. With tasks, 
 * however, the exact time at which a task operation ends after a cancel has been requested depends on the 
 * operation implementation itself. We thus cannot assume that an operation has ended right after a cancel 
 * has been sent, thus the need for a dedicated delegate method
 */
- (void)taskGroupDidCancel:(HLSTaskGroup *)taskGroup;

@end

