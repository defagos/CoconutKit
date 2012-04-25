//
//  HLSProgressTracker.h
//  CoconutKit
//
//  Created by Samuel Défago on 25.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Value returned when no remaining time estimate is available
 */
extern const NSTimeInterval HLSProgressTrackerTimeEstimateUnavailable;

// TODO: Create friend interface with progress mutator. Must not be available here
/**
 * Return an estimate about the remaining time before the task processing completes (or 
 * HLSTaskRemainingTimeEstimateUnavailable if no estimate is available yet)
 * Important remark: Accurate measurements can only be obtained if the progress update rate of a task is not 
 *                   varying fast (in another words: constant over long enough periods of time). This is for 
 *                   example usually the case for download or inflating / deflating tasks.
 * Not meant to be overridden
 */

@interface HLSProgressTracker : NSObject {
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
