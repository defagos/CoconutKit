//
//  HLSTaskGroup+Friend.h
//  nut
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
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
 * Reset internal status variables
 */
- (void)reset;

@end
