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

const float HLSURLConnectionProgressUnavailable = -1.f;

@interface HLSURLConnection ()

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSString *runLoopMode;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *internalData;
@property (nonatomic, assign) HLSURLConnectionStatus status;
@property (nonatomic, retain) HLSZeroingWeakRef *delegateZeroingWeakRef;

- (BOOL)startWithRunLoopMode:(NSString *)runLoopMode;
- (void)reset;
- (BOOL)prepareForDownload;
- (void)cleanupAfterIncompleteDownload;

@end

@implementation HLSURLConnection

#pragma mark Class methods

+ (HLSURLConnection *)connectionWithRequest:(NSURLRequest *)request runLoopMode:(NSString *)runLoopMode
{
    return [[[[self class] alloc] initWithRequest:request runLoopMode:runLoopMode] autorelease];
}

+ (HLSURLConnection *)connectionWithRequest:(NSURLRequest *)request
{
    return [[[[self class] alloc] initWithRequest:request] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request runLoopMode:(NSString *)runLoopMode
{
    if ((self = [super init])) {
        self.request = request;
        self.runLoopMode = runLoopMode;
        self.internalData = [[[NSMutableData alloc] init] autorelease];
        [self reset];
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request
{
    return [self initWithRequest:request runLoopMode:NSDefaultRunLoopMode];
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    HLSLoggerInfo(@"Connection %@ deallocated", self);
    
    self.request = nil;
    self.runLoopMode = nil;
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

@synthesize runLoopMode = m_runLoopMode;

@synthesize connection = m_connection;

@synthesize tag = m_tag;

@synthesize downloadFilePath = m_downloadFilePath;

- (void)setDownloadFilePath:(NSString *)downloadFilePath
{
    if (self.status == HLSURLConnectionStatusStarting || self.status == HLSURLConnectionStatusStarted) {
        HLSLoggerWarn(@"The download file path cannot be changed when a connection is started");
        return;
    }
    
    if (m_downloadFilePath == downloadFilePath) {
        return;
    }
    
    [m_downloadFilePath release];
    m_downloadFilePath = [downloadFilePath retain];
}

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
        return floatmin((float)m_currentContentLength / m_expectedContentLength, 1.f);
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
    if (self.status == HLSURLConnectionStatusStarting || self.status == HLSURLConnectionStatusStarted) {
        HLSLoggerWarn(@"The delegagte cannot be changed when a connection is started");
        return;
    }
    
    if (self.delegateZeroingWeakRef.object == delegate) {
        return;
    }
    
    self.delegateZeroingWeakRef = [[[HLSZeroingWeakRef alloc] initWithObject:delegate] autorelease];
    [self.delegateZeroingWeakRef addCleanupAction:@selector(cancel) onTarget:self];
}

- (NSData *)data
{
    if (self.downloadFilePath) {
        return [NSData dataWithContentsOfFile:self.downloadFilePath];
    }
    else {
        return self.internalData;
    }
}

#pragma mark Managing the connection

- (BOOL)startWithRunLoopMode:(NSString *)runLoopMode
{
    if (self.status == HLSURLConnectionStatusStarting || self.status == HLSURLConnectionStatusStarted) {
        HLSLoggerDebug(@"The connection has already been started");
        return NO;
    }
    
    if (! self.downloadFilePath && ! self.delegate) {
        HLSLoggerError(@"Cannot start a dangling connection returning data without a delegate to process it");
        return NO;
    }
    
    if (! [self prepareForDownload]) {
        return NO;
    }
    
    [self reset];
    
    // Note that NSURLConnection retains its delegate. This is why we use a zeroing weak reference for HLSURLConnection
    // delegate. Note that startImmediately has been set to NO to allow setting up the run loop mode
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO] autorelease];
    if (! self.connection) {
        HLSLoggerError(@"Unable to open connection");
        return NO;
    }
    
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    self.status = HLSURLConnectionStatusStarting;
    
    [self retain];
    
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
    [self.connection start];
    
    return YES;
}

- (void)start
{
    [self startWithRunLoopMode:self.runLoopMode];
}

- (void)cancel
{
    if (self.status != HLSURLConnectionStatusStarting && self.status != HLSURLConnectionStatusStarted) {
        HLSLoggerDebug(@"The connection has not been started");
        return;
    }
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    [self.connection cancel];
    [self cleanupAfterIncompleteDownload];
    [self reset];
    
    [self release];
}

- (void)startSynchronous
{
    // We want to share the NSURLConnection delegate code here to avoid code duplication. Ideally, we would therefore
    // like to be able to block the thread which executes -startSynchronous just after having started the
    // asynchronous NSURLConnection. If everything happened on separate threads, we could use some kind of condition 
    // variable (NSCondition) to implement the synchronous mechanism (the first threads initiates the connection,
    // spawns a second thread to receive data, and waits; the second thread does its work and signals
    // when it is done using the condition variable, at which point the first thread can resume). This
    // is not possible here, though: While a second thread receives data, the delegate events are sent back
    // for processing by the run loop associated with the thread which started the connection. If we blocked
    // it using a condition variable, we would block these events as well.
    //
    // To solve this problem, we thus need to manage the run loop ourselves, and process loop iterations
    // one by one. To filter events so that we only receive those from NSURLConnection, we schedule the
    // asynchronous connection in its own private run loop mode, and we run the run loop in this mode until
    // the NSURLConnection is done processing
    static NSString * const kHLSURLConnectionRunLoopPrivateMode = @"HLSURLConnectionRunLoopPrivateMode";
    if (! [self startWithRunLoopMode:kHLSURLConnectionRunLoopPrivateMode]) {
        return;
    }
    
    while (self.status != HLSURLConnectionStatusIdle) {
        [[NSRunLoop currentRunLoop] runMode:kHLSURLConnectionRunLoopPrivateMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)reset
{
    [self.internalData setLength:0];
    self.status = HLSURLConnectionStatusIdle;
    self.connection = nil;
    m_expectedContentLength = NSURLResponseUnknownLength;
    m_currentContentLength = 0;
}

- (BOOL)prepareForDownload
{
    if (self.downloadFilePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:self.downloadFilePath]) {
            NSError *fileDeletionError = nil;
            if ([fileManager removeItemAtPath:self.downloadFilePath error:&fileDeletionError]) {
                HLSLoggerInfo(@"A file already existed at %@ and has been deleted", self.downloadFilePath);
            }
            else {
                HLSLoggerError(@"The file existing at %@ could not be deleted. Aborting. Reason: %@", self.downloadFilePath, fileDeletionError);
                return NO;
            }    
        }
                
        NSString *downloadFileDirectoryPath = [self.downloadFilePath stringByDeletingLastPathComponent];
        NSError *directoryCreationError = nil;
        if (! [fileManager createDirectoryAtPath:downloadFileDirectoryPath
                     withIntermediateDirectories:YES 
                                      attributes:nil 
                                           error:&directoryCreationError]) {
            HLSLoggerError(@"Could not create directory %@. Aborting. Reason: %@", downloadFileDirectoryPath, directoryCreationError);
            return NO;
        }
        
        NSError *fileCreationError = nil;
        if (! [fileManager createFileAtPath:self.downloadFilePath contents:nil attributes:nil]) {
            HLSLoggerError(@"Could not create file at path %@. Aborting. Reason: %@", self.downloadFilePath, fileCreationError);
            return NO;
        }
    }
    
    return YES;
}

- (void)cleanupAfterIncompleteDownload
{
    // Remove file on failure
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.downloadFilePath]) {
        NSError *fileDeletionError = nil;
        if (! [fileManager removeItemAtPath:self.downloadFilePath error:&fileDeletionError]) {
            HLSLoggerError(@"The file at %@ could not be deleted. Reason: %@", fileDeletionError);
        }
    }
}

#pragma mark NSURLConnection events

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Each time a response is received we must discard any previously accumulated data
    // (refer to NSURLConnection documentation for more information)
    m_expectedContentLength = [response expectedContentLength];
        
    self.status = HLSURLConnectionStatusStarted;
    if ([self.delegate respondsToSelector:@selector(connectionDidStart:)]) {
        [self.delegate connectionDidStart:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.downloadFilePath) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.downloadFilePath];
        if (! fileHandle) {
            HLSLoggerError(@"The file at %@ could not be found. Aborting");
            [self cancel];
            return;
        }
        
        @try {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
        }
        @catch (NSException *exception) {
            HLSLoggerError(@"The file at %@ could not be written. Aborting. Reason: %@", exception);
            [self cancel];
            return;
        }
    }
    else {
        [self.internalData appendData:data];
    }
    
    // We track the total length. It is more cumbersome, but it is faster than querying a file for his length
    // (if we are downloading to a file)
    m_currentContentLength += [data length];
    
    if ([self.delegate respondsToSelector:@selector(connectionDidProgress:)]) {
        [self.delegate connectionDidProgress:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    HLSLoggerDebug(@"Connection failed with error: %@", error);
    
    // Remove file on failure
    [self cleanupAfterIncompleteDownload];
    
    [self reset];
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.delegate connection:self didFailWithError:error];
    }
    
    [self release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    
    self.status = HLSURLConnectionStatusIdle;
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    if ([self.delegate respondsToSelector:@selector(connectionDidFinish:)]) {
        [self.delegate connectionDidFinish:self];
    }
    
    [self release];
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
