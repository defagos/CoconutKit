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
@property (nonatomic, weak) HLSURLConnection *parentConnection;

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
        self.userCompletionBlock = completionBlock;
        
         __weak __typeof(&*self) weakSelf = self;
        self.wrapperCompletionBlock = ^(id responseObject, NSError *error){
            weakSelf.userCompletionBlock ? weakSelf.userCompletionBlock(responseObject, error) : nil;
            [weakSelf.parentConnection.childConnections removeObject:weakSelf];
            weakSelf.running = YES;
        };;
        self.childConnections = [NSMutableArray array];
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
    NSLog(@"Connection dealloced");
}

#pragma mark Accessors and mutators

- (HLSURLConnectionCompletionBlock)completionBlock
{
    return self.userCompletionBlock;
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
    [self cancelConnection];
    
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
