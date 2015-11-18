//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTask.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSTaskGroup.h"
#import "NSBundle+HLSExtensions.h"

const NSUInteger HLSTaskProgressStepsCounterThreshold = 50;
const NSTimeInterval HLSTaskNoTimeIntervalEstimateAvailable = -1.;

@interface HLSTask ()

@property (nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isFinished) BOOL finished;
@property (nonatomic, getter=isCancelled) BOOL cancelled;
@property (nonatomic) float progress;
@property (nonatomic) NSTimeInterval remainingTimeIntervalEstimate;
@property (nonatomic) NSDate *lastEstimateDate;                 // date & time when the remaining time was previously estimated
@property (nonatomic) NSDictionary *returnInfo;
@property (nonatomic) NSError *error;
@property (nonatomic, weak) HLSTaskGroup *taskGroup;            // weak ref to parent task group, nil if none

@end

@implementation HLSTask {
@private
    float _lastEstimateProgress;            // Progress value when the remaining time was previously estimated (lastEstimateDate)
    NSUInteger _progressStepsCounter;
}

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

#pragma mark Accessors and mutators

- (Class)operationClass
{
    HLSMissingMethodImplementation();
    return NULL;
}

- (void)setProgress:(float)progress
{
    // If the value has not changed, nothing to do
    if (progress == _progress) {
        return;
    }
    
    // Sanitize input
    if (isless(progress, 0.f) || isgreater(progress, 1.f)) {
        if (isless(progress, 0.f)) {
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
    if (_progressStepsCounter > HLSTaskProgressStepsCounterThreshold) {
        // Calculate estimate based on velocity during previous step (never 0 since this method returns if progress does not change)
        double progressSinceLastEstimate = progress - _lastEstimateProgress;
        if (progressSinceLastEstimate != 0.) {
            self.remainingTimeIntervalEstimate = (elapsedTimeIntervalSinceLastEstimate / progressSinceLastEstimate) * (1 - progress);
            
            // Get ready for next estimate
            _progressStepsCounter = 0;
            self.lastEstimateDate = [NSDate date];
            _lastEstimateProgress = progress;
        }
    }
}

- (NSTimeInterval)remainingTimeIntervalEstimate
{
    if (! self.finished &&  ! self.cancelled) {
        return _remainingTimeIntervalEstimate;
    }
    else {
        return HLSTaskNoTimeIntervalEstimateAvailable;
    }
}

- (NSString *)remainingTimeIntervalEstimateLocalizedString
{
    if (self.remainingTimeIntervalEstimate == HLSTaskGroupNoTimeIntervalEstimateAvailable) {
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

#pragma mark Resetting

- (void)reset
{
    self.running = NO;
    self.finished = NO;
    self.cancelled = NO;
    self.progress = 0.f;
    self.remainingTimeIntervalEstimate = HLSTaskNoTimeIntervalEstimateAvailable;
    self.lastEstimateDate = nil;
    self.returnInfo = nil;
    self.error = nil;
}

@end
