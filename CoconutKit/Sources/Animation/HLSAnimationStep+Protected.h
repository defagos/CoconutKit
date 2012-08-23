//
//  HLSAnimationStep+Protected.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSObjectAnimation.h"

@interface HLSAnimationStep (Protected)

/**
 * Setting an animation for an object
 */
- (void)addObjectAnimation:(HLSObjectAnimation *)objectAnimation forObject:(id)object;

/**
 * Retrieving the animation for an object
 */
- (HLSObjectAnimation *)objectAnimationForObject:(id)object;

/**
 * All objects changed by the animation group, returned in the order they were added to it
 */
- (NSArray *)objects;

/**
 * Playing the animation. This retains the animation step delegate if animated, and requires 
 * subclasses to call notifyDelegateAnimationStepDidStopAnimated:finished: somewhere in their 
 * implementation to free it when 
 *
 * If the duration of a step is 0, animated will be NO
 */
- (void)playAnimationAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated;

/**
 * Cancel the animation associated with the step (if running)
 */
- (void)cancelAnimation;

/**
 * The corresponding animation step to be played during the reverse animation
 */
- (id)reverseAnimationStep;

/**
 * Return a string describing the involved object animations
 */
- (NSString *)objectAnimationDescriptionString;

/**
 * To be called by subclasses in their animated animation delegates
 */
- (void)notifyDelegateAnimationStepWillStart;
- (void)notifyDelegateAnimationStepDidStopFinished:(BOOL)finished;

@end
