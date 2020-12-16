//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAnimationStep.h"
#import "HLSLayerAnimation.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A layer animation step (HLSLayerAnimationStep) is the combination of several layer animations (HLSLayerAnimation) applied
 * to a set of layers, and represent the collective set of changes applied to them during some time interval. An animation
 * (HLSAnimation) is then simply a collection of animation steps, either view-based (HLSViewAnimationStep) or layer-based
 * (HLSLayerAnimationStep).
 *
 * To create a layer animation step, simply instantiate it using the +animationStep class method, then add layer animations
 * to it, and set its duration and curve
 */
@interface HLSLayerAnimationStep : HLSAnimationStep <CAAnimationDelegate>

/**
 * Create an animation step with default settings
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

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
@property (nonatomic) CAMediaTimingFunction *timingFunction;

@end

NS_ASSUME_NONNULL_END
