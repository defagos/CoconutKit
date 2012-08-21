//
//  HLSViewAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSVector.h"

/**
 * A view animation (HLSViewAnimation) describes the changes applied to a view within an animation group 
 * (HLSViewAnimationGroup). An animation group is the combination of several view animations applied 
 * to a set of views, and represent the collective set of changes applied to them during some time interval. 
 * An animation (HLSAnimation) is then simply a collection of animation groups, either view-based
 * (HLSViewAnimationGroup) or layer-based (HLSLayerAnimationGroup).
 *
 * A view animation:
 *   - animates view frames. Those views have to correctly respond to such changes, either by setting
 *     their autoresizing mask properly, or by implementing -layoutSubviews if they need more control
 *     over the resizing process
 *   - applies only affine operations
 *
 * Designated initializer: init (create a view animation group with default settings)
 */
@interface HLSViewAnimation : NSObject <NSCopying> {
@private
    CGFloat m_rotationAngle;
    HLSVector2 m_scaleParameters;
    HLSVector2 m_translationParameters;
    CGFloat m_alphaVariation;
}

/**
 * Identity view animation
 */
+ (HLSViewAnimation *)viewAnimation;

/**
 * Geometric transform parameters to be applied during the view animation. The resulting transform (which you can 
 * obtain by calling -transform) applies the rotation, the scale and finally the translation
 */
- (void)rotateByAngle:(CGFloat)angle;
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

/**
 * Return the inverse view animation
 */
- (HLSViewAnimation *)reverseViewAnimation;

@end
