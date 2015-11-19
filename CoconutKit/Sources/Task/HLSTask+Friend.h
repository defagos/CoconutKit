//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTask.h"
#import "HLSTaskGroup.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface meant to be used by friend classes of HLSTask (= classes which must have access to private implementation
 * details)
 */
@interface HLSTask (Friend)

/**
 * Internal properties
 */
@property (nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isFinished) BOOL finished;
@property (nonatomic, getter=isCancelled) BOOL cancelled;

/**
 * Set the operation progress to 0.f (task not processed), 1.f (task fully processed), or a value in between 
 * (which should reflect an estimate about how much of the task has been processed)
 */
@property (nonatomic) float progress;

/**
 * More internal properties
 */
@property (nonatomic) NSDictionary *returnInfo;
@property (nonatomic) NSError *error;
@property (nonatomic, weak, nullable) HLSTaskGroup *taskGroup;           // weak ref to parent task group

/**
 * Reset internal status variables
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
