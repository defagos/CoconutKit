//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTaskGroup.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface meant to be used by friend classes of HLSTaskGroup (= classes which must have access to private implementation
 * details)
 */
@interface HLSTaskGroup (Friend)

/**
 * Ask the task group to refresh its status based on the current status of its tasks
 */
- (void)updateStatus;

/**
 * Internal properties
 */
@property (nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isFinished) BOOL finished;
@property (nonatomic, getter=isCancelled) BOOL cancelled;

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

NS_ASSUME_NONNULL_END
