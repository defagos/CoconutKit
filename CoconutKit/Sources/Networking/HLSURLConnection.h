//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSConnection.h"

#import <Foundation/Foundation.h>

// Completion block signatures
typedef BOOL (^HLSURLConnectionAuthenticationChallengeBlock)(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace);

/**
 * Abstract class for URL connections. Subclass and implement methods from the HLSConnectionAbstract protocol
 * to create your own concrete connection classes
 */
@interface HLSURLConnection : HLSConnection

/**
 * Create the connection. Success or failure is notified through a single completion block. Other blocks are used
 * to report download, resp. upload progress (see HLSURLConnection.h)
 */
- (instancetype)initWithRequest:(NSURLRequest *)request completionBlock:(HLSConnectionCompletionBlock)completionBlock NS_DESIGNATED_INITIALIZER;

/**
 * The request attached to the connection
 */
@property (nonatomic, readonly, strong) NSURLRequest *request;

/**
 * Authentication blocks
 */
@property (nonatomic, copy) HLSURLConnectionAuthenticationChallengeBlock authenticationChallengeBlock;

@end

@interface HLSURLConnection (UnavailableMethods)

- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
