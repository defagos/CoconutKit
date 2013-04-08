//
//  HLSFakeConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 08.04.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSConnection.h"

/**
 * A fake connection, useful when having a connection object is mandatory
 *
 * When the fake connection is started, its completion block is called with the provided response object and error.
 * Cancelling a fake connection is a no-op
 *
 * Designated initializer: -initWithResponseObject:error:completionBlock:
 */
@interface HLSFakeConnection : HLSConnection

- (id)initWithResponseObject:(id)responseObject error:(NSError *)error completionBlock:(HLSConnectionCompletionBlock)completionBlock;

@end
