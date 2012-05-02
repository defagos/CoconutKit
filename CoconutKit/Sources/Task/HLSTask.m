//
//  HLSTask.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTask.h"

#import "HLSConverters.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSRestrictedInterfaceProxy.h"
#import "HLSTaskGroup.h"

@interface HLSTask ()

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, retain) HLSProgressTracker *progressTracker;
@property (nonatomic, retain) NSDictionary *returnInfo;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, assign) HLSTaskGroup *taskGroup;           // weak ref to parent task group

- (void)reset;

@end

@implementation HLSTask

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        [self reset];
    }
    return self;
}

- (void)dealloc
{
    self.tag = nil;
    self.userInfo = nil;
    self.progressTracker = nil;
    self.returnInfo = nil;
    self.error = nil;
    self.taskGroup = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

- (Class)operationClass
{
    HLSLoggerError(@"No operation class attached to task class %@", [self class]);
    return NULL;
}

@synthesize tag = _tag;

@synthesize userInfo = _userInfo;

@synthesize running = _running;

@synthesize finished = _finished;

@synthesize cancelled = _cancelled;

@synthesize progressTracker = _progressTracker;

- (id<HLSProgressTrackerInfo>)progressTrackerInfo
{
    return [HLSRestrictedInterfaceProxy proxyWithTarget:self.progressTracker protocol:@protocol(HLSProgressTrackerInfo)];
}

@synthesize returnInfo = _returnInfo;

@synthesize error = _error;

@synthesize taskGroup = _taskGroup;

#pragma mark Resetting

- (void)reset
{
    self.running = NO;
    self.finished = NO;
    self.cancelled = NO;
    self.progressTracker = [[[HLSProgressTracker alloc] init] autorelease];
    self.returnInfo = nil;
    self.error = nil;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; running: %@; finished: %@; cancelled: %@; progressTracker: %@; error: %@>", 
            [self class],
            self,
            HLSStringFromBool(self.running),
            HLSStringFromBool(self.finished),
            HLSStringFromBool(self.cancelled),
            self.progressTracker,
            self.error];
}

@end
