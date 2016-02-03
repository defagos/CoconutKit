//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

// Forward declarations
@class HLSConnection;

// Completion block signature
typedef void (^HLSConnectionCompletionBlock)(HLSConnection *connection, id responseObject, NSError *error);
typedef void (^HLSConnectionFinalizeBlock)(NSError *error);
typedef void (^HLSConnectionProgressBlock)(int64_t completedUnitCount, int64_t totalUnitCount);

/**
 * Subclasses of HLSConnection MUST implement the set of methods declared by the following protocol
 */
@protocol HLSConnectionAbstract <NSObject>
@optional

/**
 * Start the connection, scheduling it with a given set of run loop modes. When implementing this method, you should
 * take care of calling methods from the Subclassing category to update progress and mark completion
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
 * Return YES while the connection or one of its children connections are running
 */
@property (nonatomic, readonly, assign, getter=isRunning) BOOL running;

/**
 * The last error encountered when running the connection, nil if none
 */
@property (nonatomic, readonly, strong) NSError *error;

/**
 * Connection progress information (use KVO to be notified about changes, see NSProgress documentation)
 */
@property (nonatomic, readonly, strong) NSProgress *progress;

/**
 * A progress block which gets called as the connection runs (same information as -progress, but without the need
 * for KVO)
 */
@property (nonatomic, copy) HLSConnectionProgressBlock progressBlock;

/**
 * A block called after the connection and all its child connection are finished
 */
@property (nonatomic, copy) HLSConnectionFinalizeBlock finalizeBlock;

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
 * A (dictionary) key must specified, which can be used to retrieve the connection at a later time. If you do not need
 * any key, use -addChildConnection: instead. At most one connection can be registered for a specific key
 *
 * Note that you are responsible of avoiding cycles when creating parent / child relationships, otherwise the behavior
 * is undefined
 */
- (void)addChildConnection:(HLSConnection *)connection withKey:(id)key;

/**
 * Same as -addChildConnection:withIdentifier:, but without specifiying an explicit key. The automatically generated
 * key is provided as return value for further use
 */
- (id)addChildConnection:(HLSConnection *)connection;

/**
 * Return all child connections, in no specific order
 */
@property (nonatomic, readonly, strong) NSArray *childConnections;

/**
 * Return the connection with the specified key, nil if none is found
 */
- (HLSConnection *)childConnectionForKey:(id)key;

/**
 * Remove the connection with the specified key, does nothing if none is found. The connection is automatically
 * cancelled
 */
- (void)removeChildConnectionForKey:(id)key;

@end

/**
 * Methods which subclasses must / can call to update the connection status
 */
@interface HLSConnection (Subclassing)

/**
 * The total amount of work required by the connection (if known)
 */
- (void)setTotalUnitCount:(int64_t)totalUnitCount;

/**
 * The total amount of work currently achieved by the connection (if known)
 */
- (void)updateProgressWithCompletedUnitCount:(int64_t)completedUnitCount;

/**
 * This method must be called when the connection finishes, whether it finishes normally, with an error or has
 * been cancelled. Failing to call this method in those cases results in undefined behavior (mostly memory leaks).
 */
- (void)finishWithResponseObject:(id)responseObject error:(NSError *)error;

@end
