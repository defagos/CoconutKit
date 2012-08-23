//
//  HLSViewAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSObjectAnimation.h"

#import "HLSVector.h"

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
 * Designated initializer: init (create a view animation step with default settings)
 */
@interface HLSViewAnimation : HLSObjectAnimation {
@private
    HLSVector2 m_scaleParameters;
    HLSVector2 m_translationParameters;
    CGFloat m_alphaVariation;
}

/**
 * Geometric transform parameters to be applied during the view animation. The resulting transform (which you can 
 * obtain by calling -transform) applies the rotation, the scale and finally the translation
 */
- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor;
- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y;

/**
 * Convenience method to calculate the view animation parameters needed to transform a rect into another one
 */
- (void)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

/**
 * Alpha increment or decrement to be applied during the view animation. Any value between 1.f and -1.f can be provided, 
 * though you should ensure that alpha never reaches a value outside [0, 1] during an animation.
 *
 * Default value is 0.f
 */
@property (nonatomic, assign) CGFloat alphaVariation;

/**
 * The transform corresponding to the transform parameters associated with the view animation
 *
 * If no rotation, scale or translation parameters have been set, this property returns the identity matrix
 */
@property (nonatomic, readonly, assign) CGAffineTransform transform;

@end
