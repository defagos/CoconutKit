//
//  HLSTaskManager+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/18/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSTask.h"
#import "HLSTaskGroup.h"
#import "HLSTaskOperation.h"

@interface HLSTaskManager (Friend)

/**
 * Remove an operation from the inventory. The manager itself has no way of knowing when an operation must
 * be unregistered (it is the operation which knows when it is done), except when cancelling. Polling 
 * operations is not an option, so this method has been made a friend to let operations access it
 */
- (void)unregisterOperation:(HLSTaskOperation *)operation;

/**
 * Retrieving registered delegates
 */
- (id<HLSTaskDelegate>)delegateForTask:(HLSTask *)task;
- (id<HLSTaskGroupDelegate>)delegateForTaskGroup:(HLSTaskGroup *)taskGroup;

@end
