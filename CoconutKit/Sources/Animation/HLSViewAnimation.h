//
//  HLSViewAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSObjectAnimation.h"

/**
 * A view animation (HLSViewAnimation) describes the changes applied to a view within an animation step 
 * (HLSViewAnimationStep). An animation step is the combination of several view animations applied
 * to a set of views, and represent the collective set of changes applied to them during some time interval. 
 * An animation (HLSAnimation) is then simply a collection of animation steps, either view-based
 * (HLSViewAnimationStep) or layer-based (HLSLayerAnimationStep).
 *
 * Note that a view animation:
 *   - animates view frames. The animated views have to correctly respond to such changes, either by setting
 *     their autoresizing mask properly, or by implementing -layoutSubviews if they need a finer control
 *     over the resizing process
 *   - applies only affine operations
 *
 * In general, and if you do not need to animate view frames to resize subviews during animations, you should 
 * use layer animations instead of view animations since they have far more capabilities.
 */
@interface HLSViewAnimation : HLSObjectAnimation

/**
 * Create an animation with default settings (identity, leaving the view unchanged)
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * Geometric transform parameters to be applied during the view animation. The resulting transform applies the scale, 
 * then the translation
 */
- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor;
- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y;

/**
 * Convenience method to calculate the view animation parameters needed to transform a rect into another one
 *
 * Be careful: During an animation, the frame of a view changes. If you set fromRect to view.frame, this will be
 * the frame of the view at the time the animation is created, not right before the view animation is performed. 
 * Those might be the same, but in general this is not the case!
 */
- (void)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

/**
 * Alpha increment or decrement to be applied during the view animation. Any value between 1.f and -1.f can be provided, 
 * though you should ensure that alpha never reaches a value outside [0, 1] during the course of an animation.
 */
- (void)addToAlpha:(CGFloat)alphaIncrement;

@end
