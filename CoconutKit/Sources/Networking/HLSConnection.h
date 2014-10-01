//
//  HLSConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 08.04.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

// Forward declarations
@class HLSConnection;

// Completion block signature
typedef void (^HLSConnectionCompletionBlock)(HLSConnection *connection, id responseObject, NSError *error);
typedef void (^HLSConnectionProgressBlock)(long long bytesTransferred, long long bytesTotal);

/**
 * Subclasses of HLSConnection MUST implement the set of methods declared by the following protocol
 */
@protocol HLSConnectionAbstract <NSObject>
@optional

/**
 * Start the connection, scheduling it with a given set of run loop modes. When implementing this method, you should
 * take care of calling the various completion blocks when appropriate
 *
 * If your concrete implementation cannot take into account one or several of these parameters, you should override
 * the corresponding setters to provide some feedback to the programmer (e.g. a log)
 */
- (void)startConnectionWithRunLoopModes:(NSSet *)runLoopModes;

/**
 * Cancel the connection
 */
- (void)cancelConnection;

@end

/**
 * Abstract class for connections. Subclass and implement methods from the HLSConnectionAbstract protocol to create 
 * your own concrete connection classes
 */
@interface HLSConnection : NSObject <HLSConnectionAbstract>

/**
 * Create a connection, attaching it the specified completion block (optional)
 */
- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock NS_DESIGNATED_INITIALIZER;

/**
 * Start the connection, scheduling it for the NSRunLoopCommonModes run loop modes
 */
- (void)start;

/**
 * Start the connection, scheduling it with a given set of run loop modes
 */
- (void)startWithRunLoopModes:(NSSet *)runLoopModes;

/**
 * Cancel the connection and all associated connections
 */
- (void)cancel;

/**
 * Return YES while the connection is running
 */
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

/**
 * Progress blocks
 */
@property (nonatomic, copy) HLSConnectionProgressBlock downloadProgressBlock;
@property (nonatomic, copy) HLSConnectionProgressBlock uploadProgressBlock;

/**
 * The completion block to be called when the connection completes (either normally or on failure)
 */
@property (nonatomic, readonly, copy) HLSConnectionCompletionBlock completionBlock;

/**
 * Create a parent - child relationship between the receiver and another connection. When cancelling the receiver,
 * all associated child connections will be cancelled as well. Note that a connection can at most have one parent.
 * If the parent - child relationship is established when the parent connection is not running, both the parent
 * and child connections will be started when the parent connection is started. If the parent connection is already
 * running when the parent - child relationship is established, the child connection will be automatically started
 * (with the same run loop modes as the parent connection)
 *
 * Child connections can be useful to implement cascading requests. Take for example an object which must be filled using
 * two requests. You want the process to happen as if only one connection is actually running. This can be easily achieved
 * using a child connection
 *
 * Note that you are responsible of avoiding cycles when creating parent / child relationships, otherwise the behavior
 * is undefined
 */
- (void)addChildConnection:(HLSConnection *)connection;

@end
