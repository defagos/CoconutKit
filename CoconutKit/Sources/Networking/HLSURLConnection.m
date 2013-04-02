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
#import "HLSZeroingWeakRef.h"

@interface HLSURLConnection ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy) HLSURLConnectionCompletionBlock userCompletionBlock;
@property (nonatomic, copy) HLSURLConnectionCompletionBlock wrapperCompletionBlock;
@property (nonatomic, strong) HLSURLConnection *parentConnection;   // not a weak ref. No retain cycle (the implementation ensures that no cycle
                                                                    // is createad. This makes the parent live until all child connections are
                                                                    // over (so that child connections can still be cancelled by cancelling their
                                                                    // parent, even if it ended first)

@property (nonatomic, strong) NSMutableArray *childConnections;     // contains HLSURLConnection objects

@property (nonatomic, strong) NSSet *runLoopModes;
@property (nonatomic, assign, getter=isRunning) BOOL running;

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

#pragma mark Accessors and mutators

- (void)setCompletionBlock:(HLSURLConnectionCompletionBlock)completionBlock
{
    self.wrapperCompletionBlock = ^(HLSURLConnection *connection, id responseObject, NSError *error) {
        connection.userCompletionBlock ? connection.userCompletionBlock(connection, responseObject, error) : nil;
        [connection.parentConnection.childConnections removeObject:connection];
        connection.running = YES;
    };
    self.userCompletionBlock = completionBlock;
}

- (HLSURLConnectionCompletionBlock)completionBlock
{
    return self.wrapperCompletionBlock;
}

#pragma mark Connection management

- (void)start
{
    [self startWithRunLoopModes:[NSSet setWithObject:NSRunLoopCommonModes]];
}

- (void)startWithRunLoopModes:(NSSet *)runLoopModes
{
    if (self.running) {
        HLSLoggerInfo(@"The connection is already running");
        return;
    }
    
    [self startConnectionWithRunLoopModes:runLoopModes];
    
    self.running = YES;
    self.runLoopModes = runLoopModes;
    
    for (HLSURLConnection *childConnection in self.childConnections) {
        if (! childConnection.running) {
            [childConnection startWithRunLoopModes:runLoopModes];
        }
    }
}

- (void)cancel
{
    if (self.running) {
        [self cancelConnection];
    }
    
    for (HLSURLConnection *childConnection in self.childConnections) {
        [childConnection cancel];
    }
}

#pragma mark Child connections

- (void)addChildConnection:(HLSURLConnection *)connection
{
    if (connection.parentConnection) {
        HLSLoggerWarn(@"A parent connection has already been defined");
        return;
    }
    connection.parentConnection = self;
    [self.childConnections addObject:connection];
    
    if (self.running) {
        [connection startWithRunLoopModes:self.runLoopModes];
    }
}

@end
