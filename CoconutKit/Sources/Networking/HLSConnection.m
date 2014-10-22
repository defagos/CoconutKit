//
//  HLSConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 08.04.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSConnection.h"

#import "HLSLogger.h"

@interface HLSConnection ()

@property (nonatomic, copy) HLSConnectionCompletionBlock userCompletionBlock;
@property (nonatomic, copy) HLSConnectionCompletionBlock wrapperCompletionBlock;

@property (nonatomic, strong) HLSConnection *parentConnection;   // not a weak ref. No retain cycle (the implementation ensures that no cycle
                                                                 // is createad. This makes the parent live until all child connections are
                                                                 // over (so that child connections can still be cancelled by cancelling their
                                                                 // parent, even if it ended first)

@property (nonatomic, strong) NSMutableArray *childConnections;  // contains HLSConnection objects

@property (nonatomic, strong) NSSet *runLoopModes;
@property (nonatomic, assign, getter=isRunning) BOOL running;

@end

@implementation HLSConnection

#pragma mark Object creation and destruction

- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if (self = [super init]) {
        self.completionBlock = completionBlock;
        
        self.childConnections = [NSMutableArray array];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithCompletionBlock:nil];
}

#pragma mark Accessors and mutators

- (void)setCompletionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    self.wrapperCompletionBlock = ^(HLSConnection *connection, id responseObject, NSError *error) {
        connection.userCompletionBlock ? connection.userCompletionBlock(connection, responseObject, error) : nil;
        [connection.parentConnection.childConnections removeObject:connection];
        connection.parentConnection = nil;
        connection.running = NO;
    };
    self.userCompletionBlock = completionBlock;
}

- (HLSConnectionCompletionBlock)completionBlock
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
    
    for (HLSConnection *childConnection in self.childConnections) {
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
    
    // Connections are removed from the array when terminated. We must avoid iterating the collection while this
    // might happen
    NSArray *childConnections = [NSArray arrayWithArray:self.childConnections];
    for (HLSConnection *childConnection in childConnections) {
        [childConnection cancel];
    }
}

#pragma mark HLSConnectionAbstract protocol implementation

- (void)startConnectionWithRunLoopModes:(NSSet *)runLoopModes
{
    self.completionBlock(self, nil, nil);
}

- (void)cancelConnection
{}

#pragma mark Child connections

- (void)addChildConnection:(HLSConnection *)connection
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
