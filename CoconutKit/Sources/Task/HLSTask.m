//
//  HLSTask.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTask.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSTaskGroup.h"
#import "NSBundle+HLSExtensions.h"

const NSUInteger kProgressStepsCounterThreshold = 50;

@interface HLSTask ()

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) NSTimeInterval remainingTimeIntervalEstimate;
@property (nonatomic, retain) NSDate *lastEstimateDate;
@property (nonatomic, retain) NSDictionary *returnInfo;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, assign) HLSTaskGroup *taskGroup;           // weak ref to parent task group

- (void)reset;

@end

@implementation HLSTask

#pragma mark -
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
    self.lastEstimateDate = nil;
    self.returnInfo = nil;
    self.error = nil;
    self.taskGroup = nil;
    [super dealloc];
}

#pragma mark -
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

@synthesize progress = _progress;

- (void)setProgress:(float)progress
{
    // If the value has not changed, nothing to do
    if (floateq(progress, _progress)) {
        return;
    }
    
    // Sanitize input
    if (floatlt(progress, 0.f) || floatgt(progress, 1.f)) {
        if (floatlt(progress, 0.f)) {
            _progress = 0.f;
        }
        else {
            _progress = 1.f;
        }
        HLSLoggerWarn(@"Incorrect value %f for progress value, must be between 0 and 1. Fixed", progress);
    }
    else {
        _progress = progress;
    }
    
    // Estimation is not made with each progress value change. If progress values are incremented fast, it is calculated
    // after several changes. If progress value change is slow, we use a time difference criterium. This should provide
    // accurate enough results
    if (! _lastEstimateDate) {
        _progressStepsCounter = 0;
        self.lastEstimateDate = [NSDate date];
        _lastEstimateProgress = progress;
    }
    else {
        ++_progressStepsCounter;
    }
    
    // Should update estimate?
    NSTimeInterval elapsedTimeIntervalSinceLastEstimate = [[NSDate date] timeIntervalSinceDate:self.lastEstimateDate];
    if (_progressStepsCounter > kProgressStepsCounterThreshold) {
        // Calculate estimate based on velocity during previous step (never 0 since this method returns if progress does not change)
        double progressSinceLastEstimate = progress - _lastEstimateProgress;
        if (! doubleeq(progressSinceLastEstimate, 0.)) {
            self.remainingTimeIntervalEstimate = (elapsedTimeIntervalSinceLastEstimate / progressSinceLastEstimate) * (1 - progress);
            
            // Get ready for next estimate
            _progressStepsCounter = 0;
            self.lastEstimateDate = [NSDate date];
            _lastEstimateProgress = progress;
        }
    }
}

@synthesize remainingTimeIntervalEstimate = _remainingTimeIntervalEstimate;

- (NSTimeInterval)remainingTimeIntervalEstimate
{
    if (! self.finished &&  ! self.cancelled) {
        return _remainingTimeIntervalEstimate;
    }
    else {
        return kTaskNoTimeIntervalEstimateAvailable;
    }
}

@synthesize lastEstimateDate = _lastEstimateDate;

@synthesize returnInfo = _returnInfo;

@synthesize error = _error;

@synthesize taskGroup = _taskGroup;

- (NSString *)remainingTimeIntervalEstimateLocalizedString
{
    if (self.remainingTimeIntervalEstimate == kTaskGroupNoTimeIntervalEstimateAvailable) {
        return NSLocalizedStringFromTableInBundle(@"No remaining time estimate available", @"Localizable", [NSBundle coconutKitBundle], @"No remaining time estimate available");
    }    
    
    NSTimeInterval timeInterval = self.remainingTimeIntervalEstimate;
    NSUInteger days = timeInterval / (24 * 60 * 60);
    timeInterval -= days * (24 * 60 * 60);
    NSUInteger hours = timeInterval / (60 * 60);
    timeInterval -= hours * (60 * 60);
    NSUInteger minutes = timeInterval / 60;
    
    if (days != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%dd %dh remaining (estimate)", @"Localizable", [NSBundle coconutKitBundle], @"%dd %dh remaining (estimate)"), days, hours];
    }
    else if (hours != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%dh %dm remaining (estimate)", @"Localizable", [NSBundle coconutKitBundle], @"%dh %dm remaining (estimate)"), hours, minutes];
    }
    else if (minutes != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%d min remaining (estimate)", @"Localizable", [NSBundle coconutKitBundle], @"%d min remaining (estimate)"), minutes];
    }
    else {
        return NSLocalizedStringFromTableInBundle(@"< 1 min remaining (estimate)", @"Localizable", [NSBundle coconutKitBundle], @"< 1 min remaining (estimate)");
    }
}

#pragma mark -
#pragma mark Resetting

- (void)reset
{
    self.running = NO;
    self.finished = NO;
    self.cancelled = NO;
    self.progress = 0.f;
    self.remainingTimeIntervalEstimate = kTaskNoTimeIntervalEstimateAvailable;
    self.lastEstimateDate = nil;
    self.returnInfo = nil;
    self.error = nil;
}

@end
