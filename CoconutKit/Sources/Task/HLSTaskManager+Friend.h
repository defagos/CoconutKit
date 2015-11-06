//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTask.h"
#import "HLSTaskGroup.h"
#import "HLSTaskManager.h"
#import "HLSTaskOperation.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
- (nullable id<HLSTaskDelegate>)delegateForTask:(HLSTask *)task;
- (nullable id<HLSTaskGroupDelegate>)delegateForTaskGroup:(HLSTaskGroup *)taskGroup;

@end

NS_ASSUME_NONNULL_END
