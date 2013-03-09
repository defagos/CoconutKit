//
//  HLSURLConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/6/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSURLConnection.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSURLConnection ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy) HLSURLConnectionCompletionBlock completionBlock;

@property (nonatomic, strong) NSMutableArray *childConnections;     // contains HLSURLConnection objects

@end

@implementation HLSURLConnection

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request
      completionBlock:(HLSURLConnectionCompletionBlock)completionBlock
{
    if ((self = [super init])) {
        if (! request) {
            HLSLoggerError(@"Missing request");
            return nil;
        }
        
        self.request = request;
        self.completionBlock = completionBlock;
        self.childConnections = [NSMutableArray array];
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Connection management

- (void)start
{
    [self startWithRunLoopModes:[NSSet setWithObject:NSRunLoopCommonModes]];
}

- (void)cancel
{
    [self cancelConnection];
    
    for (HLSURLConnection *childConnection in self.childConnections) {
        [childConnection cancel];
    }
}

#pragma mark Child connections

- (void)addChildConnection:(HLSURLConnection *)connection
{
    [self.childConnections addObject:connection];
    [connection start];
}

@end
