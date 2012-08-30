//
//  HLSAnimationStep+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSAnimationStepDelegate;

/**
 * Interface meant to be used by friend classes of HLSAnimationStep (= classes which must have access to private implementation
 * details)
 */
@interface HLSAnimationStep (Friend)

/**
 * Play the associated animation after some delay, reporting events to the specified delegate (which is retained during
 * the animation)
 */
- (void)playWithDelegate:(id<HLSAnimationStepDelegate>)delegate afterDelay:(NSTimeInterval)delay animated:(BOOL)animated;

/**
 * Pause the an animation step being played animated (does nothing if the animation is not running or not animated). This
 * method can also be used to pause an animation during its initial delay period
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
 * The corresponding animation step to be played during the reverse animation
 */
- (id)reverseAnimationStep;

/**
 * Return YES iff the animation has been paused
 */
@property (nonatomic, readonly, assign, getter=isPaused) BOOL paused;

@end

/**
 * The animated info which is returned is the same given when the play method was called (even if the animation
 * was actually not animated because its duration was 0)
 */
@protocol HLSAnimationStepDelegate <NSObject>

/**
 * Called when an animation step will start
 */
- (void)animationStepWillStart:(HLSAnimationStep *)animationStep animated:(BOOL)animated;

/**
 * Called when an animation step did stop. The finished boolean is YES iff the animation played until the end
 * without being terminated
 */
- (void)animationStepDidStop:(HLSAnimationStep *)animationStep animated:(BOOL)animated finished:(BOOL)finished;

@end
