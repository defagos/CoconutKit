//
//  HLSAnimationStep+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSAnimationStepDelegate;

@interface HLSAnimationStep (Friend)

/**
 * Playing the animation
 */
- (void)playWithDelegate:(id<HLSAnimationStepDelegate>)delegate afterDelay:(NSTimeInterval)delay animated:(BOOL)animated;

/**
 * Cancel the animation associated with the step (if running)
 */
- (void)cancel;

/**
 * The corresponding animation step to be played during the reverse animation
 */
- (id)reverseAnimationStep;

@end

/**
 * Subclasses are responsible of calling those methods on the delegate
 */
@protocol HLSAnimationStepDelegate <NSObject>

- (void)animationStepWillStart:(HLSAnimationStep *)animationStep animated:(BOOL)animated;
- (void)animationStepDidStop:(HLSAnimationStep *)animationStep animated:(BOOL)animated finished:(BOOL)finished;

@end
