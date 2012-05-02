//
//  HLSTaskGroup.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTaskGroup.h"

#import "HLSConverters.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSTask+Friend.h"

// Remark:
// HLSTaskGroup is not a subclass of HLSTask. This would have been nice, but this would also have introduced subtle
// issues regarding cycling task dependencies in the task composites which could have been made in this case. To
// keep everything simple (because it is already complicated enough), I chose to create two separate kinds of
// objects instead.

const NSUInteger kFullProgressStepsCounterThreshold = 50;

@interface HLSTaskGroup ()

@property (nonatomic, retain) NSMutableSet *taskSet;
@property (nonatomic, retain) NSMutableDictionary *weakTaskDependencyMap;
@property (nonatomic, retain) NSMutableDictionary *strongTaskDependencyMap;
@property (nonatomic, retain) NSMutableDictionary *taskToWeakDependentsMap;
@property (nonatomic, retain) NSMutableDictionary *taskToStrongDependentsMap;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, retain) HLSProgressTracker *progressTracker;

- (void)updateStatus;

- (NSSet *)dependenciesForTask:(HLSTask *)task;
- (NSSet *)weakDependenciesForTask:(HLSTask *)task;
- (NSSet *)strongDependenciesForTask:(HLSTask *)task;

- (NSSet *)dependentsForTask:(HLSTask *)task;
- (NSSet *)weakDependentsForTask:(HLSTask *)task;
- (NSSet *)strongDependentsForTask:(HLSTask *)task;

- (void)reset;

@end

@implementation HLSTaskGroup

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.taskSet = [NSMutableSet set];
        self.weakTaskDependencyMap = [NSMutableDictionary dictionary];
        self.strongTaskDependencyMap = [NSMutableDictionary dictionary];
        self.taskToWeakDependentsMap = [NSMutableDictionary dictionary];
        self.taskToStrongDependentsMap = [NSMutableDictionary dictionary];
        [self reset];
    }
    return self;
}

- (void)dealloc
{
    self.tag = nil;
    self.userInfo = nil;
    self.taskSet = nil;
    self.weakTaskDependencyMap = nil;
    self.strongTaskDependencyMap = nil;
    self.taskToWeakDependentsMap = nil;
    self.taskToStrongDependentsMap = nil;
    self.progressTracker = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize tag = _tag;

@synthesize userInfo = _userInfo;

@synthesize taskSet = _taskSet;

- (NSSet *)tasks
{
    return [NSSet setWithSet:self.taskSet];
}

@synthesize weakTaskDependencyMap = _weakTaskDependencyMap;

@synthesize strongTaskDependencyMap = _strongTaskDependencyMap;

@synthesize taskToWeakDependentsMap = _taskToWeakDependentsMap;

@synthesize taskToStrongDependentsMap = _taskToStrongDependentsMap;

@synthesize running = _running;

@synthesize finished = _finished;

@synthesize cancelled = _cancelled;

@synthesize progressTracker = _progressTracker;

- (id<HLSProgressTrackerInfo>)progressTrackerInfo
{
    return [HLSRestrictedInterfaceProxy proxyWithTarget:self.progressTracker protocol:@protocol(HLSProgressTrackerInfo)];
}

- (NSUInteger)numberOfFailures
{
    return _numberOfFailures;
}

#pragma mark Managing tasks

- (void)addTask:(HLSTask *)task
{
    if (self.running) {
        HLSLoggerInfo(@"Cannot add a task to a running task group");
        return;
    }
    
    [self.taskSet addObject:task];
    task.taskGroup = self;
}

#pragma mark Recalculating the task group status

- (void)updateStatus
{
    // Calculate the overall progress and status
    float progress = 0.f;
    BOOL finished = YES;
    for (HLSTask *task in self.taskSet) {
        // If at least one task is not finished, so is the task group
        if (! task.finished) {
            finished = NO;
        }
        
        // Count errors
        if (task.error) {
            ++_numberOfFailures;
        }
        
        progress += task.progressTrackerInfo.progress;
    }
    
    // Update the values stored internally
    self.progressTracker.progress = progress / [self.taskSet count];
    self.finished = finished;
}

#pragma mark -
#pragma mark Managing dependencies

- (void)addDependencyForTask:(HLSTask *)task1 onTask:(HLSTask *)task2 strong:(BOOL)strong
{
    // Check that both tasks are part of the task group
    if (! [self.taskSet containsObject:task1]) {
        HLSLoggerError(@"First task %@ does not belong to the task group set; cannot set a dependency", task1);
        return;
    }
    if (! [self.taskSet containsObject:task2]) {
        HLSLoggerError(@"Second task %@ does not belong to the task group set; cannot set a dependency", task2);
        return;
    }
    
    // Cannot set a dependency on itself!
    if (task1 == task2) {
        HLSLoggerError(@"A task cannot add itself as dependency");
    }
    
    // A dependency is either weak or strong, and cannot be registered several times
    NSValue *task1Key = [NSValue valueWithPointer:task1];
    NSMutableSet *task1WeakDependencies = [self.weakTaskDependencyMap objectForKey:task1Key];
    if ([task1WeakDependencies containsObject:task2]) {
        HLSLoggerError(@"Task %@ already registered as weak dependency on task %@", task1, task2);
        return;
    }
    
    NSMutableSet *task1StrongDependencies = [self.strongTaskDependencyMap objectForKey:task1Key];
    if ([task1StrongDependencies containsObject:task2]) {
        HLSLoggerError(@"Task %@ already registered as strong dependency on task %@", task1, task2);
        return;
    }
    
    // Register task2 in the dependencies of task1
    NSMutableDictionary *dependencyMap = strong ? self.strongTaskDependencyMap : self.weakTaskDependencyMap;
    NSMutableSet *task1Dependencies = [dependencyMap objectForKey:task1Key];
    // Create the dependency set if it does not exist
    if (! task1Dependencies) {
        task1Dependencies = [NSMutableSet set];
        [dependencyMap setObject:task1Dependencies forKey:task1Key];
    }
    [task1Dependencies addObject:task2];
    
    // Register the inverse relation, i.e. task1 in the dependents of task2
    NSMutableDictionary *taskToDependentsMap = strong ? self.taskToStrongDependentsMap : self.taskToWeakDependentsMap;
    NSValue *task2Key = [NSValue valueWithPointer:task2];
    NSMutableSet *task2Dependents = [taskToDependentsMap objectForKey:task2Key];
    // Create the depdents set if it does not exist
    if (! task2Dependents) {
        task2Dependents = [NSMutableSet set];
        [taskToDependentsMap setObject:task2Dependents forKey:task2Key];
    }
    [task2Dependents addObject:task1];
}

- (NSSet *)dependenciesForTask:(HLSTask *)task
{
    NSSet *weakDependencies = [self weakDependenciesForTask:task];
    NSSet *strongDependencies = [self strongDependenciesForTask:task];
    return [weakDependencies setByAddingObjectsFromSet:strongDependencies];
}

- (NSSet *)weakDependenciesForTask:(HLSTask *)task
{
    NSValue *taskKey = [NSValue valueWithPointer:task];
    return [NSSet setWithSet:[self.weakTaskDependencyMap objectForKey:taskKey]];
}

- (NSSet *)strongDependenciesForTask:(HLSTask *)task
{
    NSValue *taskKey = [NSValue valueWithPointer:task];
    return [NSSet setWithSet:[self.strongTaskDependencyMap objectForKey:taskKey]];    
}

- (NSSet *)dependentsForTask:(HLSTask *)task
{
    NSSet *weakDependents = [self weakDependentsForTask:task];
    NSSet *strongDependents = [self strongDependentsForTask:task];
    return [weakDependents setByAddingObjectsFromSet:strongDependents];
}

- (NSSet *)weakDependentsForTask:(HLSTask *)task
{
    NSValue *taskKey = [NSValue valueWithPointer:task];
    return [NSSet setWithSet:[self.taskToWeakDependentsMap objectForKey:taskKey]];
}

- (NSSet *)strongDependentsForTask:(HLSTask *)task
{
    NSValue *taskKey = [NSValue valueWithPointer:task];
    return [NSSet setWithSet:[self.taskToStrongDependentsMap objectForKey:taskKey]];    
}

#pragma mark Resetting

- (void)reset
{
    self.running = NO;
    self.finished = NO;
    self.cancelled = NO;
    self.progressTracker = [[[HLSProgressTracker alloc] init] autorelease];
    _numberOfFailures = 0;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; running: %@; finished: %@; cancelled: %@; progressTracker: %@>", 
            [self class],
            self,
            HLSStringFromBool(self.running),
            HLSStringFromBool(self.finished),
            HLSStringFromBool(self.cancelled),
            self.progressTracker];
}

@end
