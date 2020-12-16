//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAnimationStep.h"

#import <Foundation/Foundation.h>

// Forward declarations
@protocol HLSAnimationStepDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface meant to be used by friend classes of HLSAnimationStep (= classes which must have access to private implementation
 * details)
 */
@interface HLSAnimationStep (Friend)

/**
 * Play the associated animation (starting at startTime, 0 if the full animation must be played), reporting events to the 
 * specified delegate (which is retained during the animation)
 */
- (void)playWithDelegate:(nullable id<HLSAnimationStepDelegate>)delegate startTime:(NSTimeInterval)startTime animated:(BOOL)animated;

/**
 * Pause the animation step being played (does nothing if the animation is not running or not animated)
 */
- (void)pause;

/**
 * Resume a paused animation
 */
- (void)resume;

/**
 * Terminate the animation (if running). The delegate will still receive the willStart / didStop events
 */
- (void)terminate;

/**
 * The time elapsed since the animation step began animating (might be self.duration if the animation step does 
 * not support arbitrary start times). This method returns the actual running time, removing pauses (if any)
 */
@property (nonatomic, readonly) NSTimeInterval elapsedTime;

/**
 * The corresponding animation step to be played during the reverse animation
 */
@property (nonatomic, readonly) __kindof HLSAnimationStep *reverseAnimationStep;

/**
 * Return YES iff the animation has been paused
 */
@property (nonatomic, readonly, getter=isPaused) BOOL paused;

@end

@protocol HLSAnimationStepDelegate <NSObject>

/**
 * Called when an animation step did stop. The finished boolean is YES iff the animation played until the end
 * without being terminated. The animated info which is returned is the same given when the play method was 
 * called (even if the animation was actually not animated because its duration was 0)
 */
- (void)animationStepDidStop:(HLSAnimationStep *)animationStep animated:(BOOL)animated finished:(BOOL)finished;

@end

NS_ASSUME_NONNULL_END
