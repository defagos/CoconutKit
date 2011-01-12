//
//  HLSTaskGroup.m
//  Funds_iPad
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTaskGroup.h"

#import "HLSLogger.h"
#import "HLSTask+Friend.h"

@interface HLSTaskGroup ()

@property (nonatomic, retain) NSMutableSet *taskSet;
@property (nonatomic, retain) NSMutableDictionary *dependencyMap;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) float progress;

@end

@implementation HLSTaskGroup

#pragma mark -
#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.taskSet = [NSMutableSet set];
        self.dependencyMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.tag = nil;
    self.userInfo = nil;
    self.taskSet = nil;
    self.dependencyMap = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors and mutators

@synthesize tag = _tag;

@synthesize userInfo = _userInfo;

@synthesize taskSet = _taskSet;

- (NSSet *)tasks
{
    return [NSSet setWithSet:self.taskSet];
}

@synthesize dependencyMap = _dependencyMap;

@synthesize running = _running;

@synthesize finished = _finished;

@synthesize cancelled = _cancelled;

@synthesize progress = _progress;

- (NSUInteger)nbrFailures
{
    return _nbrFailures;
}

#pragma mark -
#pragma mark Managing tasks

- (void)addTask:(HLSTask *)task
{
    if (self.running) {
        logger_info(@"Cannot add a task to a running task group");
        return;
    }
    
    [self.taskSet addObject:task];
    task.taskGroup = self;
}

#pragma mark -
#pragma mark Recalculating the task group status

- (void)updateStatus
{
    // Calculate the overall progress and status
    float progress = 0.f;
    BOOL finished = YES;
    for (HLSTask *task in self.taskSet) {
        progress += task.progress;
        
        // If at least one task is not finished, so is the task group
        if (! task.finished) {
            finished = NO;
        }
        
        // Failed tasks increase the failure counter
        if (task.error) {
            ++_nbrFailures;
        }
    }
    progress /= [self.taskSet count];
    
    // Update the values stored internally
    self.progress = progress;
    self.finished = finished;
}

#pragma mark -
#pragma mark Managing dependencies

- (void)addDependencyForTask:(HLSTask *)task1 onTask:(HLSTask *)task2
{
    // Check that both tasks are part of the task group
    if (! [self.taskSet containsObject:task1]) {
        logger_error(@"First task does not belong to the task group set");
        return;
    }
    if (! [self.taskSet containsObject:task2]) {
        logger_error(@"Second task does not belong to the task group set");
        return;
    }
    
    // Use the task pointer as dictionary key
    NSValue *task1Key = [NSValue valueWithPointer:task1];
    
    // Add the dependency
    NSMutableSet *task1Dependencies = [self.dependencyMap objectForKey:task1Key];
    // Create the dependency set if it does not exist
    if (! task1Dependencies) {
        task1Dependencies = [NSMutableSet set];
        [self.dependencyMap setObject:task1Dependencies forKey:task1Key];
    }
    [task1Dependencies addObject:task2];
}

- (NSSet *)dependenciesForTask:(HLSTask *)task
{
    // Use the task pointer as dictionary key
    NSValue *taskKey = [NSValue valueWithPointer:task];
    
    return [NSSet setWithSet:[self.dependencyMap objectForKey:taskKey]];
}

#pragma mark -
#pragma mark Resetting

- (void)reset
{
    self.running = NO;
    self.finished = NO;
    self.cancelled = NO;
    self.progress = 0.f;
    _nbrFailures = 0;
}

@end
