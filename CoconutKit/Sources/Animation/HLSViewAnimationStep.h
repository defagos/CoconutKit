//
//  HLSViewAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"
#import "HLSViewAnimation.h"

/**
 * A view animation step (HLSViewAnimationStep) is the combination of several view animations (HLSViewAnimation) applied
 * to a set of views, and represent the collective set of changes applied to them during some time interval. An animation
 * (HLSAnimation) is then simply a collection of animation steps, either view-based (HLSViewAnimationStep) or layer-based 
 * (HLSLayerAnimationStep).
 *
 * Designated initializer: init (create an animation step with default settings)
 */
@interface HLSViewAnimationStep : HLSAnimationStep {
@private
    UIViewAnimationCurve m_curve;
}

/**
 * Setting a view animation for a view. Only one view animation can be defined at most for a view within an
 * animation step. The view is not retained
 */
- (void)addViewAnimation:(HLSViewAnimation *)viewAnimation forView:(UIView *)view;

/**
 * The animation curve to use
 *
 * Default value is UIViewAnimationCurveEaseInOut
 */
@property (nonatomic, assign) UIViewAnimationCurve curve;

@end
