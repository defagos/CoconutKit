//
//  HLSFileURLConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/6/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSFileURLConnection.h"

#import "HLSLogger.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"

@implementation HLSFileURLConnection

#pragma mark Object creation and destruction

- (instancetype)initWithRequest:(NSURLRequest *)request completionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if (! [[request URL] isFileURL]) {
        HLSLoggerError(@"The request is not a file request");
        return nil;
    }
    
    return [super initWithRequest:request completionBlock:completionBlock];
}

#pragma mark Accessors and mutators

- (void)setDownloadProgressBlock:(HLSConnectionProgressBlock)downloadProgressBlock
{
    HLSLoggerInfo(@"Progress block have not been implemented for mocked disk connections");
}

- (void)setUploadProgressBlock:(HLSConnectionProgressBlock)uploadProgressBlock
{
    HLSLoggerInfo(@"Progress block have not been implemented for mocked disk connections");
}

#pragma mark HLSConnectionAbstract protocol methods

- (void)startConnectionWithRunLoopModes:(NSSet *)runLoopModes
{
    // A latency can be added using environment variables
    NSTimeInterval delay = [[[[NSProcessInfo processInfo] environment] objectForKey:@"HLSFileURLConnectionLatency"] doubleValue]
        + arc4random_uniform(1001) / 1000.;
    if (isless(delay, 0.)) {
        HLSLoggerWarn(@"The connection latency must be >= 0. Fixed to 0");
        delay = 0.;
    }
    
    [self performSelector:@selector(retrieveFiles) withObject:nil afterDelay:delay inModes:[runLoopModes allObjects]];
}

- (void)cancelConnection
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(retrieveFiles) object:nil];
}

#pragma mark File management

- (void)retrieveFiles
{   
    NSString *filePath = [[self.request URL] relativePath];
    BOOL isDirectory = NO;
    
    // If the corresponding environment variable has been set, the connection can be set to be unreliable, in which
    // case it will have the corresponding failure probability
    double failureRate = [[[[NSProcessInfo processInfo] environment] objectForKey:@"HLSFileURLConnectionFailureRate"] doubleValue];
    if (isless(failureRate, 0.)) {
        HLSLoggerWarn(@"The failure rate must be >= 0. Fixed to 0");
        failureRate = 0.;
    }
    if (isgreater(failureRate, 1.)) {
        HLSLoggerWarn(@"The failure rate must be <= 1. Fixed to 1");
        failureRate = 1.;
    }
    double rating = arc4random_uniform(1001) / 1000.;
    if (isless(rating, failureRate)) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSURLErrorNetworkConnectionLost
                             localizedDescription:NSLocalizedString(@"Connection error", nil)];
        self.completionBlock ? self.completionBlock(self, nil, error) : nil;
        return;
    }
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSURLErrorResourceUnavailable
                             localizedDescription:CoconutKitLocalizedString(@"Not found", nil)];
        self.completionBlock ? self.completionBlock(self, nil, error) : nil;
        return;
    }
    
    NSArray *contents = nil;
    if (isDirectory) {
        NSArray *contentNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:NULL];
        
        NSMutableArray *mutableContents = [NSMutableArray array];
        for (NSString *contentName in contentNames) {
            NSURL *fileURL = [NSURL fileURLWithPath:[filePath stringByAppendingPathComponent:contentName]];
            [mutableContents addObject:fileURL];
        }
        contents = [NSArray arrayWithArray:mutableContents];
    }
    else {
        contents = @[[NSURL fileURLWithPath:filePath]];
    }
    self.completionBlock ? self.completionBlock(self, contents, nil) : nil;
}

@end
