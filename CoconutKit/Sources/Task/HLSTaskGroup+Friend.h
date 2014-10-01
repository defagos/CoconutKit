//
//  HLSTaskGroup+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

/**
 * Interface meant to be used by friend classes of HLSTaskGroup (= classes which must have access to private implementation
 * details)
 */
@interface HLSTaskGroup (Friend)

/**
 * Ask the task group to refresh its status based on the current status of its tasks
 */
- (void)updateStatus;

@property (nonatomic, assign, getter=isRunning) BOOL running;

@property (nonatomic, assign, getter=isFinished) BOOL finished;

@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

/**
 * Return the set of tasks which a task depends on
 */
- (NSSet *)dependenciesForTask:(HLSTask *)task;
- (NSSet *)weakDependenciesForTask:(HLSTask *)task;
- (NSSet *)strongDependenciesForTask:(HLSTask *)task;

/**
 * Returns the set of tasks depending on a task
 */
- (NSSet *)dependentsForTask:(HLSTask *)task;
- (NSSet *)weakDependentsForTask:(HLSTask *)task;
- (NSSet *)strongDependentsForTask:(HLSTask *)task;

/**
 * Reset internal status variables
 */
- (void)reset;

@end
