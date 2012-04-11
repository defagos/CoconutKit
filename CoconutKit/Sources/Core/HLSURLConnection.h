//
//  HLSURLConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 10.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

typedef enum {
    HLSURLConnectionStatusEnumBegin = 0,
    HLSURLConnectionStatusIdle = HLSURLConnectionStatusEnumBegin,
    HLSURLConnectionStatusStarting,
    HLSURLConnectionStatusStarted,
    HLSURLConnectionStatusEnumEnd,
    HLSURLConnectionStatusEnumSize = HLSURLConnectionStatusEnumEnd - HLSURLConnectionStatusEnumBegin
} HLSURLConnectionStatus;

extern float HLSURLConnectionProgressUnavailable;

// Forward declarations
@class HLSZeroingWeakRef;
@protocol HLSURLConnectionDelegate;

// TODO: When CoconutKit is iOS 5 only, use the formal NSURLConnectionDownloadDelegate and NSURLConnectionDataDelegate protocols
@interface HLSURLConnection : NSObject {
@private
    NSURLRequest *m_request;
    NSURLConnection *m_connection;
    NSString *m_tag;
    NSString *m_downloadFilePath;
    NSDictionary *m_userInfo;
    NSMutableData *m_internalData;
    HLSURLConnectionStatus m_status;
    long long m_expectedContentLength;
    HLSZeroingWeakRef *m_delegateZeroingWeakRef;
}

- (id)initWithRequest:(NSURLRequest *)request;

- (void)start;
- (void)cancel;

- (void)startSynchronous;

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *downloadFilePath;
@property (nonatomic, retain) NSDictionary *userInfo;

@property (nonatomic, readonly, retain) NSURLRequest *request;
@property (nonatomic, readonly, assign) HLSURLConnectionStatus status;
@property (nonatomic, readonly, assign) float progress;

- (NSData *)data;

@property (nonatomic, assign) id<HLSURLConnectionDelegate> delegate;

@end

@protocol HLSURLConnectionDelegate <NSObject>

@optional
- (void)connectionDidStart:(HLSURLConnection *)connection;
- (void)connectionDidFinish:(HLSURLConnection *)connection;
- (void)connection:(HLSURLConnection *)connection didFailWithError:(NSError *)error;

@end
