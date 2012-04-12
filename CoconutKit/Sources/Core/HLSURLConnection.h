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
 * Thin wrapper around NSURLConnection. It is tempting to implement a whole networking library, but in the end
 * NSURLConnection has all the power you usually need (caching, support for a large number of protocols, synchronous
 * and asynchronous connections, credentials, etc.).
 *
 * Using NSURLConnection has some inconveniences, though:
 *   - data must be handled manually (whether it is saved in-memory or to disk)
 *   - progress has to be calculated manually
 *   - NSURLConnection delegate is retained, which most of the time leads to a waste of resources, or to running 
 *     connections which have to be cancelled manually when the delegate is discarded. This is error-prone and often 
 *     results in connections running longer than they should in the background
 *
 * HLSURLConnection is meant to solve these issues without sacrificing the power of NSURLConnection, as many
 * networking library do (they usually work with NSURL objects and a fixed protocol, most likely HTTP). An
 * HLSURLConnection object is namely initialized with an NSURLRequest object, which means you can customize
 * it as you need, depending on the protocol you use, the caching policy you require, etc.
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
 * Start / stop an asynchronous connection. Use a delegate implementing the HLSURLConnectionDelegate protocol
 * to get information about the connection status (on the thread which started it)
 */
- (void)start;
- (void)cancel;

/**
 * Start a synchronous connection. The data retrieval itself runs asynchronously, but the call to -startSynchronous
 * only returns when this retrieval has terminated. Use a delegate implementing the HLSURLConnectionDelegate protocol 
 * to get information about the connection status (on the thread which started it)
 */
- (void)startSynchronous;

/**
 * A tag you can freely use to identify a connection
 */
@property (nonatomic, retain) NSString *tag;

/**
 * If a download file path is specified, the downloaded data will be saved to this specific location. If a file
 * already exists at this location when a start method is called, it is deleted first
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
 * The data which has been downloaded (can be partial if queried when the connection is still retrieving data)
 */
- (NSData *)data;

/**
 * The connection delegate. If a delegate has been attached to a connection and gets deallocated, the connection
 * gets automatically cancelled
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
 * can access the file saved at -downloadFilePath (if you chose this option)
 */
- (void)connectionDidFinish:(HLSURLConnection *)connection;

/**
 * The connection failed
 */
- (void)connection:(HLSURLConnection *)connection didFailWithError:(NSError *)error;

@end
