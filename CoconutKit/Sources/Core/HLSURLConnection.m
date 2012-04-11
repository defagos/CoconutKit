//
//  HLSURLConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 10.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSURLConnection.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSNotifications.h"
#import "HLSZeroingWeakRef.h"

float HLSURLConnectionProgressUnavailable = -1.f;

@interface HLSURLConnection ()

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *internalData;
@property (nonatomic, assign) HLSURLConnectionStatus status;
@property (nonatomic, retain) HLSZeroingWeakRef *delegateZeroingWeakRef;

- (void)reset;

@end

@implementation HLSURLConnection

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super init])) {
        self.request = request;
        self.internalData = [[[NSMutableData alloc] init] autorelease];
        [self reset];
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.request = nil;
    self.connection = nil;
    self.tag = nil;
    self.downloadFilePath = nil;
    self.userInfo = nil;
    self.internalData = nil;
    self.delegateZeroingWeakRef = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize request = m_request;

@synthesize connection = m_connection;

@synthesize tag = m_tag;

@synthesize downloadFilePath = m_downloadFilePath;

@synthesize userInfo = m_userInfo;

@synthesize internalData = m_internalData;

@synthesize status = m_status;

@dynamic progress;

- (float)progress
{
    if (m_expectedContentLength == NSURLResponseUnknownLength) {
        return HLSURLConnectionProgressUnavailable;
    }
    else {
        return [self.internalData length] / m_expectedContentLength;
    }
}

@synthesize delegateZeroingWeakRef = m_delegateZeroingWeakRef;

@dynamic delegate;

- (id<HLSURLConnectionDelegate>)delegate
{
    return self.delegateZeroingWeakRef.object;
}

- (void)setDelegate:(id<HLSURLConnectionDelegate>)delegate
{
    self.delegateZeroingWeakRef = [[[HLSZeroingWeakRef alloc] initWithObject:delegate] autorelease];
    [self.delegateZeroingWeakRef addCleanupAction:@selector(cancel) onTarget:self];
}

- (NSData *)data
{
    return self.internalData;
}

#pragma mark Managing the connection

- (void)start
{
    if (self.status == HLSURLConnectionStatusStarting || self.status == HLSURLConnectionStatusStarted) {
        HLSLoggerDebug(@"The connection has already been started");
        return;
    }
    
    [self reset];
    
    // Note that NSURLConnection retains its delegate. This is why we use a zeroing weak reference
    // for HLSURLConnection delegate
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self] autorelease];
    if (! self.connection) {
        HLSLoggerError(@"Unable to open connection");
        return;
    }
    
    self.status = HLSURLConnectionStatusStarting;
    
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
}

- (void)cancel
{
    if (self.status != HLSURLConnectionStatusStarting && self.status != HLSURLConnectionStatusStarted) {
        HLSLoggerDebug(@"The connection has not been started");
        return;
    }
    
    [self.connection cancel];
    [self reset];
}

- (void)startSynchronous
{
    if (self.status == HLSURLConnectionStatusStarting || self.status == HLSURLConnectionStatusStarted) {
        HLSLoggerDebug(@"The connection has already been started");
        return;
    }
    
    [self reset];
    
    self.status = HLSURLConnectionStatusStarting;
    
    // TODO: Check: The status / data should have been properly updated in the NSURLConnection callbacks. Similarly for the
    //       delegate method calls. If not, do it here
    NSError *error = nil;
    if (! [NSURLConnection sendSynchronousRequest:self.request returningResponse:NULL error:&error]) {
        HLSLoggerError(@"The connection failed. Reason: %@", error);
    }
}

- (void)reset
{
    [self.internalData setLength:0];
    self.status = HLSURLConnectionStatusIdle;
    self.connection = nil;
    m_expectedContentLength = NSURLResponseUnknownLength;
}

#pragma mark NSURLConnection events

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Each time a response is received we must discard any previously accumulated data
    // (refer to NSURLConnection documentation for more information)
    m_expectedContentLength = [response expectedContentLength];
    [self.internalData setLength:m_expectedContentLength];
    
    self.status = HLSURLConnectionStatusStarted;
    if ([self.delegate respondsToSelector:@selector(connectionDidStart:)]) {
        [self.delegate connectionDidStart:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.internalData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    HLSLoggerDebug(@"Connection failed with error: %@", error);
    
    [self reset];
    
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.delegate connection:self didFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    
    self.status = HLSURLConnectionStatusIdle;
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    if ([self.delegate respondsToSelector:@selector(connectionDidFinish:)]) {
        [self.delegate connectionDidFinish:self];
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; request: %@; tag: %@; downloadFilePath: %@; progress: %.2f>", 
            [self class],
            self,
            self.request,
            self.tag,
            self.downloadFilePath,
            self.progress];
}

@end
