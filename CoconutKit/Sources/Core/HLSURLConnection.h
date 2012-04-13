//
//  HLSURLConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 10.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// TODO: Add remaining time estimate
// TODO: Credentials
// TODO: When CoconutKit is iOS 5 only, use the formal NSURLConnectionDownloadDelegate and NSURLConnectionDataDelegate protocols
// TODO: notifyBegin/EndNetworkActivity should be executed on the main thread (update the implementation of those methods)

// The connection status
typedef enum {
    HLSURLConnectionStatusEnumBegin = 0,
    HLSURLConnectionStatusIdle = HLSURLConnectionStatusEnumBegin,               // No connection is running
    HLSURLConnectionStatusStarting,                                             // The connection has been started but has not received a response yet
    HLSURLConnectionStatusStarted,                                              // The connection has been started and has received a response
    HLSURLConnectionStatusEnumEnd,
    HLSURLConnectionStatusEnumSize = HLSURLConnectionStatusEnumEnd - HLSURLConnectionStatusEnumBegin
} HLSURLConnectionStatus;

// Value returned by the progress property when no progress estimate is available
extern const float HLSURLConnectionProgressUnavailable;

// Forward declarations
@class HLSZeroingWeakRef;
@protocol HLSURLConnectionDelegate;

/**
 * Thin wrapper around NSURLConnection. It is namely tempting to implement a whole networking library (several
 * already exist), but in the end NSURLConnection has all the power you usually need (caching, support for a 
 * large number of protocols, synchronous and asynchronous connections, credentials, etc.)
 *
 * Using NSURLConnection has some drawbacks, though:
 *   - the data must be handled manually as it is received (whether it is saved in-memory or on disk)
 *   - the progress has to be calculated manually
 *   - an NSURLConnection object retains its delegate. This decision was probably made to avoid nasty
 *     crashes (a connection trying to call a delegate method on a delegate which has been deallocated), 
 *     but if often leads to connections running longer than expected (if not cancelled when appropriate). 
 *     Consider the example of a view controller creating an NSURLConnection of which it is the delegate. 
 *     The connection must usually be cancelled when the view controller gets removed from view (otherwise 
 *     the view controller will survive until the connection terminates, which is often not what you
 *     want). Having to cancel a connection manually in such cases is cumbersome.
 *   - the synchronous method call is not appropriate for large downloads
 *   - you have to carefully retain and release the connection objects
 *
 * HLSURLConnection is meant to solve the above issues without sacrificing the power of NSURLConnection, as many
 * networking library do (they usually work with NSURL objects and a fixed protocol, most likely HTTP, which
 * means you have to get back to the good old NSURLConnection when your protocol differs). An
 * HLSURLConnection object is namely initialized with an NSURLRequest object, which means you can customize
 * it as you need, depending on the protocol you use, the caching policy you require, etc.
 *
 * Here are some features of HLSURLConnection:
 *   - data can be saved in-memory (small files) or on disk (needed for large files which won't fit in memory)
 *   - to minimize the need of having to cancel a connection manually (which you can still do if you want),
 *     connections having a delegate are automatically cancelled when their delegate is deallocated (which makes
 *     sense because the only object which was interested by connection events does not exist anymore)
 *   - a connection does not have to be retained if you do not need to cancel it manually (in which case you still
 *     need to keep a reference to it somewhere). Simply fire and forget. When the connection ends it will
 *     deallocates itself. If its delegate is deallocated first the connection will be cancelled and finally
 *     deallocated
 *   - a connection can be started asynchronously or synchronously. In both cases the same set of delegate methods
 *     will be called, which means you do not have to rewrite your code if you sometimes discover the need to
 *     switch between these modes
 *   - connection objects can carry information around (identity, data) and provide information about their progress
 *
 * HLSURLConnection is not thread-safe. You need to manage a connection from a single thread (on which you also
 * receive the associated delegate events), otherwise the behavior is undefined.
 *
 * Designated initializer: initWithRequest:runLoopMode:
 */
@interface HLSURLConnection : NSObject {
@private
    NSURLRequest *m_request;
    NSString *m_runLoopMode;
    NSURLConnection *m_connection;
    NSString *m_tag;
    NSString *m_downloadFilePath;
    NSDictionary *m_userInfo;
    NSMutableData *m_internalData;
    HLSURLConnectionStatus m_status;
    long long m_currentContentLength;
    long long m_expectedContentLength;
    HLSZeroingWeakRef *m_delegateZeroingWeakRef;
}

/**
 * Convenience constructors
 */
+ (HLSURLConnection *)connectionWithRequest:(NSURLRequest *)request runLoopMode:(NSString *)runLoopMode;
+ (HLSURLConnection *)connectionWithRequest:(NSURLRequest *)request;

/**
 * Create a connection object. The connection must be started manually when appropriate, either synchronously
 * or asynchronously, and a run loop mode must be provided (the connection is scheduled with the run loop
 * associated with the current thread). In general you should not have to care about run loop mode issues, 
 * simply use -initWithRequest:
 */
- (id)initWithRequest:(NSURLRequest *)request runLoopMode:(NSString *)runLoopMode;

/**
 * Same as -initWithRequest:runLoopMode:, with NSDefaultRunLoopMode set as run loop mode. This is perfectly
 * fine in most cases, but can be an issue when the run loop mode is changed and does not match the one
 * of the connection anymore, preventing connection delegate events from being received until the run loop
 * mode is switched back to its original value.
 *
 * When scrolling occurs, for example, the run loop mode is temporarily set to NSEventTrackingRunLoopMode,
 * inhibiting connection delegate events until scrolling ends. If this is an issue, you must use the 
 * -initWithRequest:runLoopMode: method to set a more appropriate run loop mode (most probably NSRunLoopCommonModes)
 */
- (id)initWithRequest:(NSURLRequest *)request;

/**
 * Start / stop an asynchronous connection
 */
- (void)start;
- (void)cancel;

/**
 * Start a synchronous connection. The data retrieval itself runs asynchronously, but the call to -startSynchronous
 * only returns when this retrieval has terminated
 */
- (void)startSynchronous;

/**
 * A tag you can freely use to identify a connection
 */
@property (nonatomic, retain) NSString *tag;

/**
 * If a download file path is specified, the downloaded data will be saved to this specific location. If a file
 * already exists at this location when a start method is called, it is deleted first
 *
 * The download file path cannot be changed when a connection is running
 */
@property (nonatomic, retain) NSString *downloadFilePath;

/**
 * A dictionary you can freely use to convey information about the connection
 */
@property (nonatomic, retain) NSDictionary *userInfo;

/**
 * The request with which the connection has been initialized
 */
@property (nonatomic, readonly, retain) NSURLRequest *request;

/**
 * The connection status
 */
@property (nonatomic, readonly, assign) HLSURLConnectionStatus status;

/**
 * A value in [0;1] describing the download progress. If no progress estimate is available, this method returns
 * HLSURLConnectionProgressUnavailable
 */
@property (nonatomic, readonly, assign) float progress;

/**
 * The data which has been downloaded (can be partial if queried when the connection is still retrieving data).
 * Do not call this method if the data does not fit in memory (this can happen when you downloaded a large file
 * on disk by setting a download file path)
 */
- (NSData *)data;

/**
 * The connection delegate. If a delegate has been attached to a connection and gets deallocated, the connection
 * gets automatically cancelled
 *
 * The delegate cannot be changed when a connection is running
 */
@property (nonatomic, assign) id<HLSURLConnectionDelegate> delegate;

@end

/**
 * Protocol to be implemented by delegates to receive information about the connection status
 */
@protocol HLSURLConnectionDelegate <NSObject>

@optional

/**
 * The connection has started and received a response
 */
- (void)connectionDidStart:(HLSURLConnection *)connection;

/**
 * The connection has received data. You can call the -progress method to obtain a progress estimate (if
 * available)
 */
- (void)connectionDidProgress:(HLSURLConnection *)connection;

/**
 * The connection did finish successfully. You can use -data to get the data which has been retrieved, or you
 * can access the file saved at -downloadFilePath (if you chose this option, and if the data is large)
 */
- (void)connectionDidFinish:(HLSURLConnection *)connection;

/**
 * The connection failed
 */
- (void)connection:(HLSURLConnection *)connection didFailWithError:(NSError *)error;

@end
