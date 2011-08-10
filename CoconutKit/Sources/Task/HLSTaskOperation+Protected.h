//
//  HLSTaskOperation+Protected.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Protected interface for use by subclasses of HLSTaskOperation in their implementation, and to be included
 * from their implementation file
 */
@interface HLSTaskOperation (Protected)

/**
 * Operation main method. When this method ends, be sure that no more threads which the operation might have spawned
 * is running (for simple synchronous tasks, no special care is needed)
 * This method must be overridden
 */
- (void)operationMain;

/**
 * Update the status of an operation; valid values are 0.f (task not processed), 1.f (task fully processed) or a value 
 * in between (which should reflect an estimate about how much of the task has been processed)
 * Not meant to be overridden
 */
- (void)updateProgressToValue:(float)progress;

/**
 * Call this method to attach return value information to the task processed by the operation
 * Not meant to be overridden
 */
- (void)attachReturnInfo:(NSDictionary *)returnInfo;

/**
 * Call this method to attach an error to the task processed by the operation. The task is then considered to have
 * failed
 * Not meant to be overridden
 */
- (void)attachError:(NSError *)error;

@end
