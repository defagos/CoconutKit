//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAnimationStep.h"
#import "HLSViewAnimation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A view animation step (HLSViewAnimationStep) is the combination of several view animations (HLSViewAnimation) applied
 * to a set of views, and represent the collective set of changes applied to them during some time interval. An animation
 * (HLSAnimation) is then simply a collection of animation steps, either view-based (HLSViewAnimationStep) or layer-based 
 * (HLSLayerAnimationStep).
 *
 * To create a view animation step, simply instantiate it using the +animationStep class method, then add view animations
 * to it, and set its duration and curve
 */
@interface HLSViewAnimationStep : HLSAnimationStep

/**
 * Create an animation steep with default settings
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * Setting a view animation for a view. Only one view animation can be defined at most for a view within an
 * animation step. The view is not retained
 *
 * The view animation is deeply copied to prevent further changes once assigned to a step
 */
- (void)addViewAnimation:(HLSViewAnimation *)viewAnimation forView:(UIView *)view;

/**
 * The animation curve to use
 *
 * Default value is UIViewAnimationCurveEaseInOut
 */
@property (nonatomic) UIViewAnimationCurve curve;

@end

NS_ASSUME_NONNULL_END
