//
//  HLSProgressTracker.h
//  CoconutKit
//
//  Created by Samuel Défago on 25.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSProtocolProxy.h"

/**
 * Value returned when no remaining time estimate is available
 */
extern const NSTimeInterval HLSProgressTrackerTimeEstimateUnavailable;

/**
 * Read-only access interface for HLSProgressTracker
 */
@protocol HLSProgressTracker <NSObject>

/**
 * Overall progress value (between 0.f and 1.f)
 */
@property (nonatomic, readonly, assign) float progress;

/**
 * Return an estimate about the remaining time before the task group processing completes (or 
 * HLSTaskRemainingTimeEstimateUnavailable if no estimate is available yet)
 * Important remark: Accurate measurements can only be obtained if the progress update rate of a task 
 *                   group is not varying fast (in another words: constant over long enough periods of 
 *                   time). This is most likely to happen when all tasks are similar (i.e. the underlying 
 *                   processing is similar) and roughly of the same size.
 * Not meant to be overridden
 */
@property (nonatomic, readonly, assign) NSTimeInterval remainingTimeEstimate;

/**
 * Return a localized string describing the estimated time before completion
 * Not meant to be overridden
 * (see remark of remainingTimeEstimate method)
 */
- (NSString *)remainingTimeEstimateLocalizedString;

@end

@interface HLSProgressTracker : NSObject <HLSProgressTracker> {
@private
    float _progress;
    NSTimeInterval _remainingTimeEstimate;
    NSDate *_lastEstimateDate;              // date & time when the remaining time was previously estimated ...
    float _lastEstimateProgress;            // ... and corresponding progress value 
    NSUInteger _progressStepsCounter;
}

/**
 * Overall progress value (between 0.f and 1.f). The new value must be larger than the previous one, otherwise
 * no update will be made
 */
@property (nonatomic, assign) float progress;

@end
