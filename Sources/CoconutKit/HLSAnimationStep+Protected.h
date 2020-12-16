//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAnimationStep.h"
#import "HLSObjectAnimation.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Protected interface for use by subclasses of HLSAnimationStep in their implementation, and to be included
 * from their implementation file
 */
@interface HLSAnimationStep (Protected)

/**
 * Set an animation for an object
 *
 * The object animation is deeply copied to prevent further changes once assigned to a step
 */
- (void)addObjectAnimation:(HLSObjectAnimation *)objectAnimation forObject:(id)object;

/**
 * Retrieve the animation for an object (nil if not match is found)
 */
- (nullable __kindof HLSObjectAnimation *)objectAnimationForObject:(id)object;

/**
 * All objects changed by the animation step, returned in the order they were added to it
 */
@property (nonatomic, readonly) NSArray *objects;

/**
 * Return YES iff the step is running
 */
@property (nonatomic, getter=isRunning) BOOL running;

/**
 * Return YES iff the step is being terminated
 */
@property (nonatomic, getter=isCancelling) BOOL terminating;

/**
 * This method must be implemented by subclasses to create and play the animation step (animated or not),
 * starting from startTime (0 if the full animation must be played). If your animation step subclass
 * cannot implement arbitrary start times, be sure that you override -elapsedTime to return self.duration
 * so that the animation is skipped instead of being resumed in the middle
 *
 * If animated = YES, the animation is expected to take place asynchronously, otherwise synchronously
 *
 * The super method implementation must not be called (it raises an exception)
 */
- (void)playAnimationWithStartTime:(NSTimeInterval)startTime animated:(BOOL)animated;

/**
 * This method must be implemented by subclasses to pause a running animation step
 *
 * The super method implementation must not be called (it raises an exception)
 */
- (void)pauseAnimation;

/**
 * This method must be implemented by subclasses to resume a paused animation step
 *
 * The super method implementation must not be called (it raises an exception)
 */
- (void)resumeAnimation;

/**
 * This method must be implemented by subclasses to return YES iff an animation step is paused
 *
 * The super method implementation must not be called (it raises an exception)
 */
@property (nonatomic, readonly, getter=isAnimationPaused) BOOL animationPaused;

/**
 * This method must be implemented by subclasses to terminate the animation
 *
 * The super method implementation must not be called (it raises an exception)
 */
- (void)terminateAnimation;

/**
 * The corresponding animation step to be played during the reverse animation
 *
 * The super method implementation must be called first
 */
@property (nonatomic, readonly) __kindof HLSAnimationStep *reverseAnimationStep;

/**
 * The time elapsed since the animation step began animating. If your animation step subclass cannot support
 * arbitrary start times, return self.duration. This method must return the actual running time, removing 
 * pauses (if any)
 *
 * The super method implementation must not be called (it raises an exception)
 */
@property (nonatomic, readonly) NSTimeInterval elapsedTime;

/**
 * Return a string describing the involved object animations
 */
@property (nonatomic, readonly, copy) NSString *objectAnimationsDescriptionString;

/**
 * Subclasses must register themselves for the asynchronous delegate events of the animation they implement,
 * and must call this method stop delegate method. The finished parameter must be set to YES iff the animation 
 * could run to completion without being cancelled
 */
- (void)notifyAsynchronousAnimationStepDidStopFinished:(BOOL)finished;

@end

NS_ASSUME_NONNULL_END
