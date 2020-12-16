//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSConnection.h"

#import "HLSLogger.h"
#import "HLSTransformer.h"
#import "NSError+HLSExtensions.h"

@interface HLSConnection ()

@property (nonatomic, copy) HLSConnectionCompletionBlock completionBlock;

@property (nonatomic, weak) HLSConnection *parentConnection;
@property (nonatomic) HLSConnection *parentStrongConnection;                                        // Ensure the parent connection lives at least until all child connections are over

@property (nonatomic) NSMutableDictionary<id, HLSConnection *> *childConnectionsDictionary;

@property (nonatomic) NSSet *runLoopModes;
@property (nonatomic, getter=isFinished) BOOL finished;
@property (nonatomic, getter=isSelfRunning) BOOL selfRunning;                                       // Is self running or not (NOT including child connections)

@property (nonatomic) NSError *error;
@property (nonatomic) NSProgress *progress;

@end

@implementation HLSConnection

#pragma mark Object creation and destruction

- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if (self = [super init]) {
        self.completionBlock = completionBlock;
        self.childConnectionsDictionary = [NSMutableDictionary dictionary];
        self.progress = [NSProgress progressWithTotalUnitCount:1];          // Will be updated by subclasses
    }
    return self;
}

- (instancetype)init
{
    return [self initWithCompletionBlock:nil];
}

- (void)dealloc
{
    self.parentStrongConnection = nil;
}

#pragma mark Accessors and mutators

- (BOOL)isRunning
{
    if (self.selfRunning) {
        return YES;
    }
    
    for (HLSConnection *childConnection in self.childConnectionsDictionary.allValues) {
        if (childConnection.selfRunning) {
            return YES;
        }
    }
    return NO;
}

#pragma mark Connection management

- (void)start
{
    [self startWithRunLoopModes:[NSSet setWithObject:NSRunLoopCommonModes]];
}

- (void)startWithRunLoopModes:(NSSet *)runLoopModes
{
    NSParameterAssert(runLoopModes);
    
    if (self.running) {
        HLSLoggerInfo(@"The connection is already running");
        return;
    }
    
    if (runLoopModes.count == 0) {
        HLSLoggerError(@"No run loop modes have been specified");
        return;
    }
    
    self.selfRunning = YES;
    self.finished = NO;
    self.runLoopModes = runLoopModes;
    
    // Start child connections first. This ensures correct behavior even if the -startConnectionWithRunLoopModes:
    // subclass implementation directly calls -finishWithResponseObject:error:
    for (HLSConnection *childConnection in self.childConnectionsDictionary.allValues) {
        if (! childConnection.selfRunning) {
            [childConnection startWithRunLoopModes:runLoopModes];
        }
    }
    
    [self updateProgressWithCompletedUnitCount:0];
    [self startConnectionWithRunLoopModes:runLoopModes];
}

- (void)cancel
{
    if (self.selfRunning) {
        [self cancelConnection];
    }
    
    for (HLSConnection *childConnection in self.childConnectionsDictionary.allValues) {
        [childConnection cancel];
    }
}

- (void)endConnection
{
    if (! self.finalizeBlock) {
        return;
    }
    
    NSError *error = [self.error copy];
    
    for (HLSConnection *childConnection in self.childConnectionsDictionary.allValues) {
        [NSError combineError:childConnection.error withError:&error];
    }
    
    self.finalizeBlock(error);
}

#pragma mark HLSConnectionAbstract protocol implementation

- (void)startConnectionWithRunLoopModes:(NSSet *)runLoopModes
{}

- (void)cancelConnection
{}

#pragma mark Child connections

- (void)addChildConnection:(HLSConnection *)connection withKey:(id)key
{
    NSParameterAssert(connection);
    NSParameterAssert(key);
    
    if (self.childConnectionsDictionary[key]) {
        HLSLoggerError(@"A connection has already been registered for key %@", key);
        return;
    }
    
    if (connection.parentConnection) {
        HLSLoggerError(@"A parent connection has already been defined");
        return;
    }
    connection.parentConnection = self;
    connection.parentStrongConnection = self;
    self.childConnectionsDictionary[key] = connection;
    
    if (self.selfRunning) {
        [connection startWithRunLoopModes:self.runLoopModes];
    }
}

- (id)addChildConnection:(HLSConnection *)connection
{
    NSParameterAssert(connection);
    
    NSString *key = [NSUUID UUID].UUIDString;
    [self addChildConnection:connection withKey:key];
    return key;
}

- (NSArray<HLSConnection *> *)childConnections
{
    return self.childConnectionsDictionary.allValues;
}

- (HLSConnection *)childConnectionForKey:(id)key
{
    NSParameterAssert(key);
    
    return self.childConnectionsDictionary[key];
}

- (void)removeChildConnectionForKey:(id)key
{
    NSParameterAssert(key);
    
    HLSConnection *connection = self.childConnectionsDictionary[key];
    if (! connection) {
        return;
    }
    
    [connection cancel];
    [self.childConnectionsDictionary removeObjectForKey:key];
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
    // Setting completed unit count to total unit count only gives a fraction completed of 1 if total is not 0. Fix the
    // total value if this is the case
    if (self.progress.totalUnitCount == 0) {
        self.progress.totalUnitCount = 1;
    }
    [self updateProgressWithCompletedUnitCount:self.progress.totalUnitCount];
    
    self.finished = YES;
    self.error = error;
    self.completionBlock ? self.completionBlock(self, responseObject, error) : nil;
    self.selfRunning = NO;
    
    if (! self.running) {
        [self endConnection];
    }
    
    if (self.parentConnection && ! self.parentConnection.running) {
        [self.parentConnection endConnection];
    }
    
    self.parentStrongConnection = nil;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; running: %@; finished: %@; error: %@; progress: %@; childConnections: %@>",
            [self class],
            self,
            HLSStringFromBool(self.running),
            HLSStringFromBool(self.finished),
            self.error,
            self.progress,
            self.childConnections];
}

@end
