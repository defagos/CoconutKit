//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTask.h"
#import "HLSTaskGroup.h"

#import <Foundation/Foundation.h>

/**
 * Interface meant to be used by friend classes of HLSTask (= classes which must have access to private implementation
 * details)
 */
@interface HLSTask (Friend)

@property (nonatomic, assign, getter=isRunning) BOOL running;

@property (nonatomic, assign, getter=isFinished) BOOL finished;

@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

/**
 * Set the operation progress to 0.f (task not processed), 1.f (task fully processed), or a value in between 
 * (which should reflect an estimate about how much of the task has been processed)
 */
@property (nonatomic, assign) float progress;

@property (nonatomic, strong) NSDictionary *returnInfo;

@property (nonatomic, strong) NSError *error;

@property (nonatomic, weak) HLSTaskGroup *taskGroup;           // weak ref to parent task group

/**
 * Reset internal status variables
 */
- (void)reset;

@end
