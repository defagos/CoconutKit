//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSConnection.h"

#import <Foundation/Foundation.h>

/**
 * A fake connection, useful when having a connection object is mandatory
 *
 * When the fake connection is started, its completion block is called with the provided response object and error. If
 * cancelled, the completion block is called with the NSURLErrorCancelled error code in the NSURLErrorDomain domain
 */
@interface HLSFakeConnection : HLSConnection

- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error completionBlock:(HLSConnectionCompletionBlock)completionBlock NS_DESIGNATED_INITIALIZER;

@end
