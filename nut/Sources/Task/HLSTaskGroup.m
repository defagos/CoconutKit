//
//  HLSTaskGroup.m
//  Funds_iPad
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTaskGroup.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSTask+Friend.h"
#import "HLSTaskGroup+Friend.h"

const NSUInteger kFullProgressStepsCounterThreshold = 50;
const NSTimeInterval kFullProgressStepsTimeIntervalThreshold = 5.;           // 5 seconds

@interface HLSTaskGroup ()

@property (nonatomic, retain) NSMutableSet *taskSet;
@property (nonatomic, retain) NSMutableDictionary *dependencyMap;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float fullProgress;
@property (nonatomic, assign) NSTimeInterval remainingTimeIntervalEstimate;
@property (nonatomic, retain) NSDate *lastEstimateDate;

@end

@implementation HLSTaskGroup

#pragma mark -
#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.taskSet = [NSMutableSet set];
        self.dependencyMap = [NSMutableDictionary dictionary];
        [self reset];
    }
    return self;
}

- (void)dealloc
{
    self.tag = nil;
    self.userInfo = nil;
    self.taskSet = nil;
    self.dependencyMap = nil;
    self.lastEstimateDate = nil;
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

@synthesize fullProgress = _fullProgress;

- (void)setFullProgress:(float)fullProgress
{
    // If the value has not changed, nothing to do
    if (floateq(fullProgress, _fullProgress)) {
        return;
    }
    
    // Sanitize input
    if (floatlt(fullProgress, 0.f) || floatgt(fullProgress, 1.f)) {
        if (floatlt(fullProgress, 0.f)) {
            _fullProgress = 0.f;
        }
        else {
            _fullProgress = 1.f;
        }
        logger_warn(@"Incorrect value %f for full progress value, must be between 0 and 1. Fixed", fullProgress);
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
    if (_fullProgressStepsCounter > kFullProgressStepsCounterThreshold || elapsedTimeIntervalSinceLastEstimate > kFullProgressStepsTimeIntervalThreshold) {
        // Calculate estimate based on velocity during previous step
        double fullProgressSinceLastEstimate = fullProgress - _lastEstimateFullProgress;
        if (! doubleeq(fullProgressSinceLastEstimate, 0.)) {
            self.remainingTimeIntervalEstimate = (elapsedTimeIntervalSinceLastEstimate / fullProgressSinceLastEstimate) * (1 - fullProgress);
            
            // Get ready for next estimate
            _fullProgressStepsCounter = 0;
            self.lastEstimateDate = [NSDate date];
            _lastEstimateFullProgress = fullProgress;
        }
    }
}

@synthesize remainingTimeIntervalEstimate = _remainingTimeIntervalEstimate;

- (NSTimeInterval)remainingTimeIntervalEstimate
{
    if (! self.finished && ! self.cancelled) {
        return _remainingTimeIntervalEstimate;
    }
    else {
        return kTaskGroupNoTimeIntervalEstimateAvailable;
    }
}

@synthesize lastEstimateDate = _lastEstimateDate;


- (NSUInteger)nbrFailures
{
    return _nbrFailures;
}

- (NSString *)remainingTimeIntervalEstimateLocalizedString
{
    if (self.remainingTimeIntervalEstimate == kTaskGroupNoTimeIntervalEstimateAvailable) {
        return NSLocalizedStringFromTable(@"No remaining time estimate available", @"nut_Localizable", @"No remaining time estimate available");
    }
    
    NSTimeInterval timeInterval = self.remainingTimeIntervalEstimate;
    NSUInteger days = timeInterval / (24 * 60 * 60);
    timeInterval -= days * (24 * 60 * 60);
    NSUInteger hours = timeInterval / (60 * 60);
    timeInterval -= hours * (60 * 60);
    NSUInteger minutes = timeInterval / 60;
    
    if (days != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%dd %dh remaining (estimate)", @"nut_Localizable", @"%dd %dh remaining (estimate)"), days, hours];
    }
    else if (hours != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%dh %dm remaining (estimate)", @"nut_Localizable", @"%dh %dm remaining (estimate)"), hours, minutes];
    }
    else if (minutes != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d min remaining (estimate)", @"nut_Localizable", @"%d min remaining (estimate)"), minutes];
    }
    else {
        return NSLocalizedStringFromTable(@"< 1 min remaining (estimate)", @"nut_Localizable", @"< 1 min remaining (estimate)");
    }
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
    self.fullProgress = 0.f;
    self.remainingTimeIntervalEstimate = kTaskGroupNoTimeIntervalEstimateAvailable;
    self.lastEstimateDate = nil;
    _nbrFailures = 0;
}

@end
