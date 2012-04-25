//
//  HLSProgressTracker.m
//  CoconutKit
//
//  Created by Samuel Défago on 25.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSProgressTracker.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

const NSUInteger kProgressStepsCounterThreshold = 50;

const NSTimeInterval HLSProgressTrackerTimeEstimateUnavailable = -1.;

@interface HLSProgressTracker ()

@property (nonatomic, assign) NSTimeInterval remainingTimeEstimate;
@property (nonatomic, retain) NSDate *lastEstimateDate;

@end

@implementation HLSProgressTrackerInfo

@end

@implementation HLSProgressTracker

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.remainingTimeEstimate = HLSProgressTrackerTimeEstimateUnavailable;
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize progress = _progress;

- (void)setProgress:(float)progress
{
    // Sanitize input
    if (floatlt(progress, 0.f) || floatgt(progress, 1.f)) {
        HLSLoggerWarn(@"Incorrect value %f for progress value, must be between 0 and 1. Fixed", progress);
        
        if (floatlt(progress, 0.f)) {
            progress = 0.f;
        }
        else {
            progress = 1.f;
        }
    }
    
    // Must increase
    if (floatle(progress, _progress)) {
        return;
    }
    
    _progress = progress;
        
    // Estimation is not made with each progress value change. If progress values are incremented fast, it is calculated
    // after several changes. If progress value change is slow, we use a time difference criterium. This should provide
    // accurate enough results
    if (! self.lastEstimateDate) {
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
            self.remainingTimeEstimate = (elapsedTimeIntervalSinceLastEstimate / progressSinceLastEstimate) * (1 - progress);
            
            // Get ready for next estimate
            _progressStepsCounter = 0;
            self.lastEstimateDate = [NSDate date];
            _lastEstimateProgress = progress;
        }
    }
}

@synthesize remainingTimeEstimate = _remainingTimeEstimate;

@synthesize lastEstimateDate = _lastEstimateDate;

- (NSString *)remainingTimeEstimateLocalizedString
{
    if (self.remainingTimeEstimate == HLSProgressTrackerTimeEstimateUnavailable) {
        return NSLocalizedStringFromTable(@"Unavailable", @"CoconutKit_Localizable", @"Unavailable");
    }    
    
    NSTimeInterval timeInterval = self.remainingTimeEstimate;
    NSUInteger days = timeInterval / (24 * 60 * 60);
    timeInterval -= days * (24 * 60 * 60);
    NSUInteger hours = timeInterval / (60 * 60);
    timeInterval -= hours * (60 * 60);
    NSUInteger minutes = timeInterval / 60;
    
    if (days != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%dd %dh remaining", @"CoconutKit_Localizable", @"%dd %dh remaining"), days, hours];
    }
    else if (hours != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%dh %dm remaining", @"CoconutKit_Localizable", @"%dh %dm remaining"), hours, minutes];
    }
    else if (minutes != 0) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d min remaining", @"CoconutKit_Localizable", @"%d min remaining"), minutes];
    }
    else {
        return NSLocalizedStringFromTable(@"< 1 min remaining", @"CoconutKit_Localizable", @"< 1 min remaining");
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; progress: %f; remainingTimeEstimate: %f>", 
            [self class],
            self,
            self.progress,
            self.remainingTimeEstimate];
}

@end
