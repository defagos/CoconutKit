//
//  HLSTask+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSProgressTracker.h"
#import "HLSTaskGroup.h"

/**
 * Interface meant to be used by friend classes of HLSTask (= classes which must have access to private implementation
 * details)
 */
@interface HLSTask (Friend)

@property (nonatomic, retain) HLSProgressTracker *progressTracker;

@property (nonatomic, assign, getter=isRunning) BOOL running;

@property (nonatomic, assign, getter=isFinished) BOOL finished;

@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

@property (nonatomic, retain) NSDictionary *returnInfo;

@property (nonatomic, retain) NSError *error;

@property (nonatomic, assign) HLSTaskGroup *taskGroup;           // weak ref to parent task group

/**
 * Reset internal status variables
 */
- (void)reset;

@end
