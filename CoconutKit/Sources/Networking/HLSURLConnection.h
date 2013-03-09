//
//  HLSURLConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Completion block signature
typedef void (^HLSURLConnectionCompletionBlock)(id responseObject, NSError *error);
typedef void (^HLSURLConnectionProgressBlock)(long long bytesTransferred, long long bytesTotal);
typedef BOOL (^HLSURLConnectionAuthenticationChallengeBlock)(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace);

/**
 * Subclasses of HLSURLConnection MUST implement the set of methods declared by the following protocol
 */
@protocol HLSURLConnectionAbstract <NSObject>
@optional

/**
 * Start the connection, scheduling it with a given set of run loop modes. When implementing this method, you should
 * take care of calling the various completion blocks when appropriate
 *
 * If your concrete implementation cannot take into account one or several of these parameters, you should override
 * the corresponding setters to provide some feedback to the programmer (e.g. a log)
 */
- (void)startWithRunLoopModes:(NSSet *)runLoopModes;

/**
 * Cancel the connection
 */
- (void)cancelConnection;

@end

/**
 * Abstract class for URL connections. Subclass and implement methods from the HLSURLConnectionAbstract protocol 
 * to create your own concrete connection classes
 *
 * Designated initializer: -initWithRequets:completionBlock:
 */
@interface HLSURLConnection : NSObject <HLSURLConnectionAbstract>

/**
 * Create the connection. Success or failure is notified through a single completion block. Other blocks are used
 * to report download, resp. upload progress
 */
- (id)initWithRequest:(NSURLRequest *)request
      completionBlock:(HLSURLConnectionCompletionBlock)completionBlock;

/**
 * Start the connection, scheduling it for the NSRunLoopCommonModes run loop modes
 */
- (void)start;

/**
 * Cancel the connection and all associated connections
 */
- (void)cancel;

/**
 * Connection immutable properties
 */
@property (nonatomic, readonly, strong) NSURLRequest *request;
@property (nonatomic, readonly, copy) HLSURLConnectionCompletionBlock completionBlock;

/**
 * Progress blocks
 */
@property (nonatomic, copy) HLSURLConnectionProgressBlock downloadProgressBlock;
@property (nonatomic, copy) HLSURLConnectionProgressBlock uploadProgressBlock;

/**
 * Authentication blocks
 */
@property (nonatomic, copy) HLSURLConnectionAuthenticationChallengeBlock authenticationChallengeBlock;

/**
 * Create a parent - child relationship between the receiver and another connection. When cancelling the receiver,
 * all associated child connections will be cancelled as well. When a connection is added as child connection, it
 * is automatically started for you
 *
 * Child connections can be useful to implement cascading requests. Take for example an object which must be filled using 
 * two requests. You want the process to happen as if only one connection is actually running. This can be easily achieved
 * using a child connection
 *
 * Note that you are responsible of avoiding cycles when creating parent / child relationships, otherwise the behavior
 * is undefined
 */
- (void)addChildConnection:(HLSURLConnection *)connection;

@end
