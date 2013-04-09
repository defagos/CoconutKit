//
//  HLSURLConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSConnection.h"

// Completion block signatures
typedef BOOL (^HLSURLConnectionAuthenticationChallengeBlock)(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace);

/**
 * Abstract class for URL connections. Subclass and implement methods from the HLSConnectionAbstract protocol
 * to create your own concrete connection classes
 *
 * Designated initializer: -initWithRequest:completionBlock:
 */
@interface HLSURLConnection : HLSConnection

/**
 * Create the connection. Success or failure is notified through a single completion block. Other blocks are used
 * to report download, resp. upload progress (see HLSURLConnection.h)
 */
- (id)initWithRequest:(NSURLRequest *)request completionBlock:(HLSConnectionCompletionBlock)completionBlock;

/**
 * The request attached to the connection
 */
@property (nonatomic, readonly, strong) NSURLRequest *request;

/**
 * Authentication blocks
 */
@property (nonatomic, copy) HLSURLConnectionAuthenticationChallengeBlock authenticationChallengeBlock;

@end
