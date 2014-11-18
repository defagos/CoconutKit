//
//  HLSTaskGroup.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSTaskGroup.h"

#import "HLSLogger.h"
#import "HLSTask+Friend.h"
#import "NSBundle+HLSExtensions.h"

// Remark:
// HLSTaskGroup is not a subclass of HLSTask. This would have been nice, but this would also have introduced subtle
// issues regarding cycling task dependencies in the task composites which could have been made in this case. To
// keep everything simple (because it is already complicated enough), I chose to create two separate kinds of
// objects instead.

const NSUInteger kFullProgressStepsCounterThreshold = 50;

@interface HLSTaskGroup ()

@property (nonatomic, strong) NSMutableSet *taskSet;                                    // contains HLSTask objects

// Dependencies between tasks are saved in both directions for faster lookup
@property (nonatomic, strong) NSMutableDictionary *weakTaskDependencyMap;               // maps an HLSTask object to the NSMutableSet of all other HLSTask objects it weakly depends on
@property (nonatomic, strong) NSMutableDictionary *strongTaskDependencyMap;             // maps an HLSTask object to the NSMutableSet of all other HLSTask objects it strongly depends on
@property (nonatomic, strong) NSMutableDictionary *taskToWeakDependentsMap;             // maps an HLSTask object to the NSMutableSet of all HLSTask objects weakly depending on it
@property (nonatomic, strong) NSMutableDictionary *taskToStrongDependentsMap;           // maps an HLSTask object to the NSMutableSet of all HLSTask objects strongly depending on it

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) float progress;                                           // all individual progress values added
@property (nonatomic, assign) float fullProgress;                                       // all individual progress values added (failures count as 1.f). 1 - _fullProgress is remainder
@property (nonatomic, assign) NSTimeInterval remainingTimeIntervalEstimate;             // date & time when the remaining time was previously estimated ...
@property (nonatomic, strong) NSDate *lastEstimateDate;

@end

@implementation HLSTaskGroup {
@private
    float _lastEstimateFullProgress;            // the progress value when the remaining time was previously estimated (lastEstimateDate)
    NSUInteger _fullProgressStepsCounter;
    NSUInteger _nbrFailures;
}

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.taskSet = [NSMutableSet set];
        self.weakTaskDependencyMap = [NSMutableDictionary dictionary];
        self.strongTaskDependencyMap = [NSMutableDictionary dictionary];
        self.taskToWeakDependentsMap = [NSMutableDictionary dictionary];
        self.taskToStrongDependentsMap = [NSMutableDictionary dictionary];
        [self reset];
    }
    return self;
}

#pragma mark Accessors and mutators

- (NSSet *)tasks
{
    return [NSSet setWithSet:self.taskSet];
}

- (void)setFullProgress:(float)fullProgress
{
    // If the value has not changed, nothing to do
    if (fullProgress == _fullProgress) {
        return;
    }
    
    // Sanitize input
    if (isless(fullProgress, 0.f) || isgreater(fullProgress, 1.f)) {
        if (isless(fullProgress, 0.f)) {
            _fullProgress = 0.f;
        }
        else {
            _fullProgress = 1.f;
        }
        HLSLoggerWarn(@"Incorrect value %f for full progress value, must be between 0 and 1. Fixed", fullProgress);
    }
    else {
        _fullProgress = fullProgress;
    }    
    
    // Estimation is not made with each progress value change. If progress values are incremented fast, it is calculated
    // after several changes. If progress value change is slow, we use a time difference criterium. This should provide
    // accurate enough results
    if (! _lastEstimateDate) {
        _fullProgressStepsCounter = 0;
        self.lastEstimateDate = [NSDate date];
        _lastEstimateFullProgress = fullProgress;
    }
    else {
        ++_fullProgressStepsCounter;
    }
    
    // Should update estimate?
    NSTimeInterval elapsedTimeIntervalSinceLastEstimate = [[NSDate date] timeIntervalSinceDate:self.lastEstimateDate];
    if (_fullProgressStepsCounter > kFullProgressStepsCounterThreshold) {
        // Calculate estimate based on velocity during previous step
        double fullProgressSinceLastEstimate = fullProgress - _lastEstimateFullProgress;
        if (fullProgressSinceLastEstimate != 0.) {
            self.remainingTimeIntervalEstimate = (elapsedTimeIntervalSinceLastEstimate / fullProgressSinceLastEstimate) * (1 - fullProgress);
            
            // Get ready for next estimate
            _fullProgressStepsCounter = 0;
            self.lastEstimateDate = [NSDate date];
            _lastEstimateFullProgress = fullProgress;
        }
    }
}

- (NSTimeInterval)remainingTimeIntervalEstimate
{
    if (! self.finished && ! self.cancelled) {
        return _remainingTimeIntervalEstimate;
    }
    else {
        return kTaskGroupNoTimeIntervalEstimateAvailable;
    }
}

- (NSUInteger)nbrFailures
{
    return _nbrFailures;
}

- (NSString *)remainingTimeIntervalEstimateLocalizedString
{
    if (self.remainingTimeIntervalEstimate == kTaskGroupNoTimeIntervalEstimateAvailable) {
        return CoconutKitLocalizedString(@"No remaining time estimate available", nil);
    }
    
    NSTimeInterval timeInterval = self.remainingTimeIntervalEstimate;
    NSUInteger days = timeInterval / (24 * 60 * 60);
    timeInterval -= days * (24 * 60 * 60);
    NSUInteger hours = timeInterval / (60 * 60);
    timeInterval -= hours * (60 * 60);
    NSUInteger minutes = timeInterval / 60;
    
    if (days != 0) {
        return [NSString stringWithFormat:CoconutKitLocalizedString(@"%dd %dh remaining (estimate)", nil), days, hours];
    }
    else if (hours != 0) {
        return [NSString stringWithFormat:CoconutKitLocalizedString(@"%dh %dm remaining (estimate)", nil), hours, minutes];
    }
    else if (minutes != 0) {
        return [NSString stringWithFormat:CoconutKitLocalizedString(@"%d min remaining (estimate)", nil), minutes];
    }
    else {
        return CoconutKitLocalizedString(@"< 1 min remaining (estimate)", nil);
    }
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
    float fullProgress = 0.f;
    BOOL finished = YES;
    for (HLSTask *task in self.taskSet) {
        progress += task.progress;
        
        // If at least one task is not finished, so is the task group
        if (! task.finished) {
            finished = NO;
        }
        
        // Failed tasks increase the failure counter and count for 1 in fullProgress
        if (task.error) {
            fullProgress += 1.f;
            ++_nbrFailures;
        }
        else {
            fullProgress += task.progress;
        }
    }
    progress /= [self.taskSet count];
    fullProgress /= [self.taskSet count];
    
    // Update the values stored internally
    self.progress = progress;
    self.fullProgress = fullProgress;
    self.finished = finished;
}

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
    NSValue *task1Key = [NSValue valueWithNonretainedObject:task1];
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
    NSValue *task2Key = [NSValue valueWithNonretainedObject:task2];
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
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    return [NSSet setWithSet:[self.weakTaskDependencyMap objectForKey:taskKey]];
}

- (NSSet *)strongDependenciesForTask:(HLSTask *)task
{
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
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
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    return [NSSet setWithSet:[self.taskToWeakDependentsMap objectForKey:taskKey]];
}

- (NSSet *)strongDependentsForTask:(HLSTask *)task
{
    NSValue *taskKey = [NSValue valueWithNonretainedObject:task];
    return [NSSet setWithSet:[self.taskToStrongDependentsMap objectForKey:taskKey]];    
}

#pragma mark Resetting

- (void)reset
{
    self.running = NO;
    self.finished = NO;
    self.cancelled = NO;
    self.progress = 0.f;
    self.fullProgress = 0.f;
    self.remainingTimeIntervalEstimate = kTaskGroupNoTimeIntervalEstimateAvailable;
    self.lastEstimateDate = nil;
    _nbrFailures = 0;
}

@end
