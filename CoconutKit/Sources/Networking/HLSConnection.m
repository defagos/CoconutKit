//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HLSConnection.h"

#import "HLSLogger.h"

@interface HLSConnection ()

@property (nonatomic, copy) HLSConnectionCompletionBlock completionBlock;

@property (nonatomic, strong) HLSConnection *parentConnection;   // not a weak ref. No retain cycle (the implementation ensures that no cycle
                                                                 // is created. This makes the parent live until all child connections are
                                                                 // over (so that child connections can still be cancelled by cancelling their
                                                                 // parent, even if it ended first)

@property (nonatomic, strong) NSMutableArray *childConnections;  // contains HLSConnection objects

@property (nonatomic, strong) NSSet *runLoopModes;
@property (nonatomic, assign, getter=isRunning) BOOL running;

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation HLSConnection

#pragma mark Object creation and destruction

- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if (self = [super init]) {
        self.completionBlock = completionBlock;
        self.childConnections = [NSMutableArray array];
        self.progress = [NSProgress progressWithTotalUnitCount:0];          // Will be updated by subclasses
    }
    return self;
}

- (instancetype)init
{
    return [self initWithCompletionBlock:nil];
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
    
    [self updateProgressWithCompletedUnitCount:0];
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
    
    // Connections are removed from the array when terminated. We must avoid iterating the collection while this might happen
    NSArray *childConnections = [NSArray arrayWithArray:self.childConnections];
    for (HLSConnection *childConnection in childConnections) {
        [childConnection cancel];
    }
}

#pragma mark HLSConnectionAbstract protocol implementation

- (void)startConnectionWithRunLoopModes:(NSSet *)runLoopModes
{}

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

#pragma mark Methods to be called by subclasses

- (void)setTotalUnitCount:(int64_t)totalUnitCount
{
    self.progress.totalUnitCount = totalUnitCount;
}

- (void)updateProgressWithCompletedUnitCount:(int64_t)completedUnitCount
{
    self.progress.completedUnitCount = completedUnitCount;
    self.progressBlock ? self.progressBlock(self.progress.completedUnitCount, self.progress.totalUnitCount) : nil;
}

- (void)finishWithResponseObject:(id)responseObject error:(NSError *)error
{
    [self updateProgressWithCompletedUnitCount:self.progress.totalUnitCount];
    self.error = error;
    
    self.completionBlock ? self.completionBlock(self, responseObject, error) : nil;
    [self.parentConnection.childConnections removeObject:self];
    self.parentConnection = nil;
    self.running = NO;
}

@end
