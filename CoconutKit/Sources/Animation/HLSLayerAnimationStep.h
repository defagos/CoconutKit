//
//  HLSLayerAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"
#import "HLSLayerAnimation.h"

/**
 * A layer animation step (HLSLayerAnimationStep) is the combination of several layer animations (HLSLayerAnimation) applied
 * to a set of layers, and represent the collective set of changes applied to them during some time interval. An animation
 * (HLSAnimation) is then simply a collection of animation steps, either view-based (HLSViewAnimationStep) or layer-based
 * (HLSLayerAnimationStep).
 *
 * To create a layer animation step, simply instantiate it using the +animationStep class method, then add layer animations
 * to it, and set its duration and curve
 *
 * Designated initializer: -init (create an animation step with default settings)
 */
@interface HLSLayerAnimationStep : HLSAnimationStep {
@private
    CAMediaTimingFunction *m_timingFunction;
    UIView *m_dummyView;
    NSUInteger m_numberOfLayerAnimations;
    BOOL m_numberOfStartedLayerAnimations;
    NSUInteger m_numberOfFinishedLayerAnimations;
    CFTimeInterval m_startTime;
    CFTimeInterval m_pauseTime;
    CFTimeInterval m_previousPauseDuration;
}

/**
 * Setting a layer animation for a layer. Only one layer animation can be defined at most for a layer within an
 * animation step. The layer is not retained
 *
 * The layer animation is deeply copied to prevent further changes once assigned to a step
 */
- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forLayer:(CALayer *)layer;

/**
 * Convenience method to add a layer animation for a view layer
 */
- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forView:(UIView *)view;

/**
 * The animation timing function to use
 *
 * Default value is the function corresponding to the kCAMediaTimingFunctionEaseInEaseOut constant
 */
@property (nonatomic, retain) CAMediaTimingFunction *timingFunction;

@end
