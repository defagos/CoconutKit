//
//  HLSURLConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 10.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// TODO: Add remaining time estimate
// TODO: When CoconutKit is iOS 5 only, use the formal NSURLConnectionDownloadDelegate and NSURLConnectionDataDelegate protocols

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
 *     but if often leads to connections running longer than expected if not cancelled when appropriate
 *   - the synchronous method call is not appropriate for large downloads
 *   - you have to carefully retain and release connection objects
 *   - the network activity indicator must be managed manually
 *   - HTTP connections: HTTP responses with status codes >= 400 are not treated as failures and must be
 *     handled specifically
 *
 * HLSURLConnection is meant to solve the above issues without sacrificing the power of NSURLConnection, as many
 * networking library do (they usually work with NSURL objects and a fixed protocol, most likely HTTP, which
 * means you have to get back to the good old NSURLConnection when your protocol differs). An HLSURLConnection 
 * object is namely initialized with an NSURLRequest object, which means you can customize it as you need, 
 * depending on the protocol you use, the caching policy you require, etc.
 *
 * Here are some features of HLSURLConnection:
 *   - data can be saved in-memory (small files) or on disk (needed for large files which won't fit in memory)
 *   - to minimize the need of having to cancel a connection manually, connections having a delegate are automatically 
 *     cancelled when their delegate is deallocated (which makes sense because the only object which was interested by 
 *     connection events does not exist anymore). This does not remove the need to cancel connections manually
 *     in some cases, though (e.g. when the delegate is a view controller which disappears without being deallocated 
 *     right afterwards)
 *   - you do not need to keep a reference to a connection if you do not need to cancel it manually. Simply create 
 *     an autoreleased HLSURLConnection object and call an asynchronous start method on it right aftwerwards. The 
 *     connection object will survive during the time it is active. When the connection ends the connection
 *     object will be deallocated automatically. If a delegate has been attached to the connection, and if this 
 *     delegate gets deallocated before the connection ends, the connection will be cancelled, which also leads to
 *     correct deallocation
 *   - a connection can be started asynchronously or (quasi-)synchronously. In both cases the same set of delegate 
 *     methods will be called, which means you do not have to rewrite your code if you sometimes discover the need to
 *     switch between these synchronous and asynchronous behaviors. This is also why the synchronous mode is only 
 *     quasi-synchronous in reality: The call to the start method blocks, but the thread is not blocked as it continues 
 *     to process connection delegate events
 *   - connection objects can carry information around (identity, custom data) and provide information about their 
 *     progress
 *   - the network activity indicator is managed automatically
 *   - HTTP responses with status codes >= 400 are treated as failures by default. A boolean value allows the original
 *     NSURLConnection to be used instead (e.g. if one really needs to access the HTTP body)
 *
 * HLSURLConnection is not thread-safe. You need to manage a connection from a single thread (on which you also
 * receive the associated delegate events), otherwise the behavior is undefined.
 *
 * Designated initializer: initWithRequest:
 */
@interface HLSURLConnection : NSObject {
@private
    NSURLRequest *m_request;
    NSURLConnection *m_connection;
    NSString *m_tag;
    NSString *m_downloadFilePath;
    BOOL m_treatingHTTPErrorsAsFailures;
    NSDictionary *m_userInfo;
    NSMutableData *m_internalData;
    HLSURLConnectionStatus m_status;
    long long m_currentLength;
    long long m_expectedLength;
    HLSZeroingWeakRef *m_delegateZeroingWeakRef;
}

/**
 * Convenience constructor
 */
+ (HLSURLConnection *)connectionWithRequest:(NSURLRequest *)request;

/**
 * Create a connection object
 */
- (id)initWithRequest:(NSURLRequest *)request;

/**
 * Start the connection asynchronously. The method returns YES iff the connection could be started successfully.
 *
 * A connection which has no delegate and no download file path cannot be started. Such connections namely make no
 * sense (the data cannot be retrieved anywhere)
 *
 * The connection is scheduled in the current thread run loop with NSDefaultRunLoopMode set as run loop mode. This
 * is perfectly sufficient in most cases, but can be an issue when the run loop mode is changed (most probably
 * by code which you cannot change, e.g. by system frameworks) and does not match the one of the connection anymore, 
 * preventing connection delegate events from being received until the run loop mode is switched back to its original 
 * value.
 *
 * When scrolling occurs, for example, the run loop mode is temporarily set to NSEventTrackingRunLoopMode,
 * inhibiting connection delegate events until scrolling ends. If this is an issue, you must use the 
 * -startWithRunLoopMode: method to set a more appropriate run loop mode (most probably NSRunLoopCommonModes) 
 */
- (BOOL)start;

/**
 * Start the connection asynchronously. The method returns YES iff the connection could be started successfully.
 *
 * A connection which has no delegate and no download file path cannot be started. Such connections namely make no
 * sense (the data cannot be retrieved anywhere)
 *
 * The connection is scheduled in the current thread run loop using the specified mode. In most cases you do
 * not have to care about run loop mode issues, and calling -start suffices. Refer to the -start documentation
 * for more information
 */
- (BOOL)startWithRunLoopMode:(NSString *)runLoopMode;

/**
 * Cancel an asynchronous connection
 */
- (void)cancel;

/**
 * Start the connection (quasi-)synchronously. The data retrieval itself runs asynchronously and the connection delegate
 * events are still processed by the same thread which called -startSynchronous. The call to -startSynchronous itself,
 * though, only returns when the connection has ended.
 *
 * The method returns YES iff the connection could be started successfully.
 *
 * A connection which has no delegate and no download file path cannot be started. Such connections namely make no
 * sense (the data cannot be retrieved anywhere)
 */
- (BOOL)startSynchronous;

/**
 * A tag you can freely use to identify a connection
 */
@property (nonatomic, retain) NSString *tag;

/**
 * If a download file path is specified, the downloaded data will be saved to this specific location. If a file
 * already exists at this location when a connection starts, it is deleted first. If the connection fails or
 * is cancelled, the incomplete file is discarded
 *
 * The download file path cannot be changed when a connection is running
 */
@property (nonatomic, retain) NSString *downloadFilePath;

/**
 * If this property is set to YES, HTTP requests receiving status codes >= 400 are treated as connection failures 
 * (which means -connection:didFailWithError: will get called on the delegate, if any). The error received
 * belongs to the HLSCoconutKitErrorDomain, has the status code as error code, and a localized description
 * (returned by the system)
 *
 * If set to NO, responses with status codes >= 400 are not treated as connection failures (which means
 * -connectionDidFinishLoading: will be called in the end if nothing bad happens while downloading data). Usually, 
 * this is useful if you want to implement your own behavior when receiving a response with status code >= 400
 * in -connection:didReceiveResponse: (e.g. you might decide to cancel the connection in such cases)
 *
 * This setting is ignored for non-HTTP requests, and cannot be changed when a connection is running
 *
 * Default value is YES
 */
@property (nonatomic, assign, getter=isTreatingHTTPErrorsAsFailures) BOOL treatingHTTPErrorsAsFailures;

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
 * Do not call this method if the data does not fit in memory (this can happen when you download a large file).
 * In such cases, set a download file path and check the file instead
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
 * URL redirection. Refer to the documentation of the same method of NSURLConnectionDataDelegate for more information
 */
- (NSURLRequest *)connection:(HLSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

/**
 * The connection has started and received a response
 */
- (void)connection:(HLSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

/**
 * The connection has received data. You can call the -progress method to obtain a progress estimate (if available)
 */
- (void)connectionDidReceiveData:(HLSURLConnection *)connection;

/**
 * The connection did finish successfully. You can use -data to get the data which has been retrieved, or you
 * can access the file saved at -downloadFilePath (if you chose this option)
 */
- (void)connectionDidFinishLoading:(HLSURLConnection *)connection;

/**
 * The connection failed
 */
- (void)connection:(HLSURLConnection *)connection didFailWithError:(NSError *)error;

/**
 * The connection was cancelled. A delegate method is required since cancel operations are not always initiated by
 * the caller: A connection can namely be cancelled if it has a delegate which gets deallocated
 */
- (void)connectionDidCancel:(HLSURLConnection *)connection;

/**
 * Managing credentials. Refer to the documentation of the same methods of NSURLConnectionDelegate for more information
 */
- (void)connectionShouldUseCredentialStorage:(HLSURLConnection *)connection;
- (void)connection:(HLSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/**
 * Response caching. Refer to the documentation of the same method of NSURLConnectionDataDelegate for more information
 */
- (NSCachedURLResponse *)connection:(HLSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;

@end
