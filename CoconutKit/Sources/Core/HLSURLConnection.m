//
//  HLSURLConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 10.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSURLConnection.h"

#import "HLSAssert.h"
#import "HLSError.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSNotifications.h"
#import "HLSZeroingWeakRef.h"

const float HLSURLConnectionProgressUnavailable = -1.f;

@interface HLSURLConnection ()

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *internalData;
@property (nonatomic, assign) HLSURLConnectionStatus status;
@property (nonatomic, retain) HLSZeroingWeakRef *delegateZeroingWeakRef;

- (BOOL)isRunning;
- (NSString *)debugNameCapitalized:(BOOL)capitalized;
- (NSURL *)url;

- (void)resetDownloadStatusVariables;

- (BOOL)createDownloadFile;
- (BOOL)deleteDownloadFile;

// TODO: Can be removed when formal NSURLConnection delegate protocols are used
// Informal protocol method called directly in the code. Needs to be declarated
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

@implementation HLSURLConnection

#pragma mark Class methods

+ (HLSURLConnection *)connectionWithRequest:(NSURLRequest *)request
{
    return [[[[self class] alloc] initWithRequest:request] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super init])) {
        self.request = request;
        self.internalData = [[[NSMutableData alloc] init] autorelease];
        self.treatingHTTPErrorsAsFailures = YES;
        
        [self resetDownloadStatusVariables];
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

- (void)setDownloadFilePath:(NSString *)downloadFilePath
{
    if ([self isRunning]) {
        HLSLoggerWarn(@"The download file path cannot be changed while %@ is running", [self debugNameCapitalized:NO]);
        return;
    }
    
    if (m_downloadFilePath == downloadFilePath) {
        return;
    }
    
    [m_downloadFilePath release];
    m_downloadFilePath = [downloadFilePath retain];
}

@synthesize treatingHTTPErrorsAsFailures = m_treatingHTTPErrorsAsFailures;

- (void)setTreatingHTTPErrorsAsFailures:(BOOL)treatingHTTPErrorsAsFailures
{
    if ([self isRunning]) {
        HLSLoggerWarn(@"The treatingHTTPErrorsAsFailures setting cannot be changed while %@ is running", [self debugNameCapitalized:NO]);
        return;
    }
    
    m_treatingHTTPErrorsAsFailures = treatingHTTPErrorsAsFailures;
}

@synthesize userInfo = m_userInfo;

@synthesize internalData = m_internalData;

@synthesize status = m_status;

@dynamic progress;

- (float)progress
{
    if (m_expectedLength == NSURLResponseUnknownLength) {
        return HLSURLConnectionProgressUnavailable;
    }
    else {
        return floatmin((float)m_currentLength / m_expectedLength, 1.f);
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
    if ([self isRunning]) {
        HLSLoggerWarn(@"The delegate cannot be changed while %@ is running", [self debugNameCapitalized:NO]);
        return;
    }
    
    if (self.delegateZeroingWeakRef.object == delegate) {
        return;
    }
    
    // Use a zeroing weak reference:
    //   - to avoid propagating the delegate retain semantics of NSURLConnection further to HLSURLConnection delegate
    //   - to be able to cancel the connection when the delegate gets deallocated
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

- (BOOL)isRunning
{
    return self.status == HLSURLConnectionStatusStarting || self.status == HLSURLConnectionStatusStarted;
}

- (NSString *)debugNameCapitalized:(BOOL)capitalized
{
    NSString *connectionIdentifier = self.tag ? [NSString stringWithFormat:@"'%@'", self.tag] : [NSString stringWithFormat:@"(%@)", self];
    if (capitalized) {
        return [NSString stringWithFormat:@"The connection %@", connectionIdentifier];
    }
    else {
        return [NSString stringWithFormat:@"the connection %@", connectionIdentifier];
    }
}

- (NSURL *)url
{
    return [self.request URL];
}

#pragma mark Starting and stopping the connection

/**
 * Start an asynchronous connection scheduled in the current run loop with the specified mode. Returns YES iff
 * the connection could successfully be starteds
 */
- (BOOL)startWithRunLoopMode:(NSString *)runLoopMode
{
    if ([self isRunning]) {
        HLSLoggerDebug(@"%@ has already been started", [self debugNameCapitalized:YES]);
        return NO;
    }
    
    // A connection with no delegate nor file path cannot be started. This does not make sense, the downloaded
    // data would go nowhere
    if (! self.downloadFilePath && ! self.delegate) {
        HLSLoggerError(@"Cannot start %@. Connections must have least have an associated delegate or a download path", [self debugNameCapitalized:NO]);
        return NO;
    }
    
    // Perform the setup required when downloading to a file (delete any existing file first)
    if (self.downloadFilePath) {
        if (! [self deleteDownloadFile]) {
            return NO;
        }
        
        if (! [self createDownloadFile]) {
            return NO;
        }
    }
    
    // Note that NSURLConnection retains its delegate. This is why we use a zeroing weak reference for HLSURLConnection
    // delegate. startImmediately has been set to NO to allow setting up the run loop mode before the connection is started
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO] autorelease];
    if (! self.connection) {
        HLSLoggerError(@"Unable to open %@", [self debugNameCapitalized:NO]);
        return NO;
    }
        
    // Makes it possible to run connections without keeping any strong reference to them. The corresponding release will be
    // made when the connection ends
    [self retain];
    
    // Setup initial state
    [self resetDownloadStatusVariables];
    self.status = HLSURLConnectionStatusStarting;
    
    // Start the connection
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
    [self.connection start];
    
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    return YES;
}

- (BOOL)start
{
    return [self startWithRunLoopMode:NSDefaultRunLoopMode];
}

- (void)cancel
{
    if (! [self isRunning]) {
        HLSLoggerDebug(@"%@ has not been started", [self debugNameCapitalized:YES]);
        return;
    }
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    [self.connection cancel];
    self.connection = nil;
    
    // Cleanup to restore a state as if the connection had never been started
    [self deleteDownloadFile];
    [self resetDownloadStatusVariables];
    
    if ([self.delegate respondsToSelector:@selector(connectionDidCancel:)]) {
        [self.delegate connectionDidCancel:self];
    }
    
    // See -startWithRunLoopMode implementation
    [self release];
}

- (BOOL)startSynchronous
{
    // We want to share the NSURLConnection delegate method implementations here to avoid code duplication. Ideally, 
    // we would therefore like to be able to block the thread which executes -startSynchronous just after having started 
    // the asynchronous NSURLConnection. If everything happened separately on two threads, we could use some kind of 
    // condition variable (NSCondition) to implement the synchronous mechanism (the first thread initiates the connection,
    // spawns a second thread to receive data, and waits for the condition to be signaled; the second thread does its work 
    // and signals when it is done using the condition variable, at which point the first thread can resume). This
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
        return NO;
    }
    
    while (self.status != HLSURLConnectionStatusIdle) {
        [[NSRunLoop currentRunLoop] runMode:kHLSURLConnectionRunLoopPrivateMode beforeDate:[NSDate distantFuture]];
    }
    
    return YES;
}

#pragma mark Managing the connection internal status and resources

/**
 * Reset internal variables to a state similar to the one corresponding to a download about to start
 */
- (void)resetDownloadStatusVariables
{
    [self.internalData setLength:0];
    self.status = HLSURLConnectionStatusIdle;
    m_expectedLength = NSURLResponseUnknownLength;
    m_currentLength = 0;
}

#pragma mark Downloading to a file

- (BOOL)createDownloadFile
{
    if (! self.downloadFilePath) {
        // Nothing to do, successful
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create the destination directory
    NSString *downloadFileDirectoryPath = [self.downloadFilePath stringByDeletingLastPathComponent];
    NSError *directoryCreationError = nil;
    if (! [fileManager createDirectoryAtPath:downloadFileDirectoryPath
                 withIntermediateDirectories:YES 
                                  attributes:nil 
                                       error:&directoryCreationError]) {
        HLSLoggerError(@"Could not create destination directory %@. Aborting %@. Reason: %@", downloadFileDirectoryPath, 
                       [self debugNameCapitalized:NO], directoryCreationError);
        return NO;
    }
    
    // Create the destination file
    if (! [fileManager createFileAtPath:self.downloadFilePath contents:nil attributes:nil]) {
        HLSLoggerError(@"Could not create file at path %@. Aborting %@", self.downloadFilePath, [self debugNameCapitalized:NO]);
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteDownloadFile
{
    if (! self.downloadFilePath) {
        // Nothing to do, successful
        return YES;
    }
    
    // Remove file on failure
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.downloadFilePath]) {
        NSError *fileDeletionError = nil;
        if (! [fileManager removeItemAtPath:self.downloadFilePath error:&fileDeletionError]) {
            HLSLoggerError(@"The file at %@ could not be deleted. Reason: %@", self.downloadFilePath, fileDeletionError);
            return NO;
        }
    }
    
    return YES;
}

#pragma mark NSURLConnection (formal and informal) delegate protocol methods

- (NSURLRequest *)connection:(HLSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        return [self.delegate connection:self willSendRequest:request redirectResponse:response];
    }
    else {
        return request;
    }
}

// This method may be called several times. Each time a response is received we must discard any previously accumulated data
// (refer to NSURLConnection documentation for more information)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    m_expectedLength = [response expectedContentLength];
    [self.internalData setLength:0];
        
    // Treat HTTP errors as failures. Credit for the original idea goes to Cédric Lüthi (https://github.com/0xced/CLURLConnection)
    if (self.treatingHTTPErrorsAsFailures) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger statusCode = [httpResponse statusCode];
            if (statusCode >= 400) {
                NSString *localizedDescription = [NSString stringWithFormat:NSLocalizedStringFromTable(@"HTTP error: %@ (%d)", @"CoconutKit_Localizable", @"HTTP error: %@ (%d)"),
                                                  [NSHTTPURLResponse localizedStringForStatusCode:statusCode],
                                                  statusCode];
                HLSError *error = [HLSError errorWithDomain:HLSCoconutKitErrorDomain 
                                                       code:statusCode 
                                       localizedDescription:localizedDescription];
                
                // To avoid code duplication, calls NSURLConnection delegate method. The connection just needs to be
                // cancelled first
                NSAssert(connection == self.connection, @"Invalid connection");
                [self.connection cancel];
                [self connection:self.connection didFailWithError:error];
                return;
            }
        }        
    }
    
    self.status = HLSURLConnectionStatusStarted;
    
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.delegate connection:self didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append to the file
    if (self.downloadFilePath) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.downloadFilePath];
        if (! fileHandle) {
            HLSLoggerError(@"The file at %@ could not be found. Aborting %@", self.downloadFilePath, [self debugNameCapitalized:NO]);
            [self cancel];
            return;
        }
        
        @try {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
        }
        @catch (NSException *exception) {
            HLSLoggerError(@"The file at %@ could not be written. Aborting %@. Reason: %@", self.downloadFilePath, 
                           [self debugNameCapitalized:NO], exception);
            [self cancel];
            return;
        }
    }
    // Save in-memory
    else {
        [self.internalData appendData:data];
    }
    
    // We track the total length. It could be tempting to simply use [[self data] length], but this does not work
    // when downloading large files!
    m_currentLength += [data length];
    
    if ([self.delegate respondsToSelector:@selector(connectionDidReceiveData:)]) {
        [self.delegate connectionDidReceiveData:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    HLSLoggerDebug(@"%@ failed with error: %@", [self debugNameCapitalized:NO], error);
    
    NSAssert(connection == self.connection, @"Invalid connection");
    self.connection = nil;
    
    // Cleanup
    [self deleteDownloadFile];
    [self resetDownloadStatusVariables];
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.delegate connection:self didFailWithError:error];
    }
    
    [self release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSAssert(connection == self.connection, @"Invalid connection");
    self.connection = nil;
    
    self.status = HLSURLConnectionStatusIdle;
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.delegate connectionDidFinishLoading:self];
    }
    
    [self release];
}

- (BOOL)connectionShouldUseCredentialStorage:(HLSURLConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
        return [self.delegate connectionShouldUseCredentialStorage:self];
    }
    else {
        return YES;
    }
}

- (void)connection:(HLSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([self.delegate respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)]) {
        [self.delegate connection:self willSendRequestForAuthenticationChallenge:challenge];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    if ([self.delegate respondsToSelector:@selector(connection:willCacheResponse:)]) {
        return [self.delegate connection:self willCacheResponse:cachedResponse];
    }
    else {
        return cachedResponse;
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
