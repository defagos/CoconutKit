//
//  HLSLayerAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/20/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSObjectAnimation.h"

#import "HLSVector.h"

/**
 * A layer animation (HLSLayerAnimation) describes the changes applied to a layer within an animation step
 * (HLSLayerAnimationStep). An animation step is the combination of several layer animations applied
 * to a set of layers, and represent the collective set of changes applied to them during some time interval.
 * An animation (HLSAnimation) is then simply a collection of animation steps, either view-based
 * (HLSViewAnimationStep) or layer-based (HLSLayerAnimationStep).
 *
 * A layer animation animates layer transforms, not frames. This choice was made because frame animation would 
 * restrict transforms to affine transforms, for which HLSViewAnimation can be used instead (provided the layer 
 * belongs to a view, of course). Moreover, unlike views, layers do not layout their sublayers automatically based 
 * on autoresizing properties in iOS (the -[CALayer layoutSublayers] or -[UIView layoutSublayersOfLayer:] methods
 * have to be implemented to respond to frame changes)
 *
 * Since the layer transform is animated, none of the -[CALayer layoutSublayers] or -[UIView layoutSublayersOfLayer:] 
 * methods need to be implemented for layers which are animated.
 *
 * In general, and if you do not need to animate view frames to resize subviews during animations, you should
 * use layer animations instead of view animations since they have far more capabilities.
 *
 * Designated initializer: init (create a layer animation step with default settings)
 */
@interface HLSLayerAnimation : HLSObjectAnimation {
@private
    HLSVector4 m_rotationParameters;
    HLSVector3 m_scaleParameters;
    HLSVector3 m_translationParameters;
    HLSVector3 m_anchorPointTranslationParameters;
    HLSVector4 m_sublayerRotationParameters;
    HLSVector3 m_sublayerScaleParameters;
    HLSVector3 m_sublayerTranslationParameters;
    CGFloat m_sublayerSkewIncrement;
    CGFloat m_opacityIncrement;
}

/**
 * Geometric transform parameters to be applied during the layer animation. The resulting transform applies the rotation, 
 * the scale and finally the translation
 */
- (void)rotateByAngle:(CGFloat)angle aboutVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor zFactor:(CGFloat)zFactor;
- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;

/**
 * Same geometric transforms as above, but for transforms in a plane (the most common case)
 */
- (void)rotateByAngle:(CGFloat)angle;
- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor;
- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y;

/**
 * Anchor point translation
 */
- (void)translateAnchorPointByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)translateAnchorPointByVectorWithX:(CGFloat)x y:(CGFloat)y;

/**
 * Geometric transform parameters to be applied to sublayers during the layer animation. In particular, tweaking the
 * skew parameter enables perspective to be applied to subviews, adding 3D to your animations
 */
- (void)rotateSublayersByAngle:(CGFloat)angle aboutVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)scaleSublayersWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor zFactor:(CGFloat)zFactor;
- (void)translateSublayersByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)addToSublayersSkew:(CGFloat)skewIncrement;

/**
 * Same geometric transforms as above, but for transforms in a plane (the most common case)
 */
- (void)rotateSublayersByAngle:(CGFloat)angle;
- (void)scaleSublayersWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor;
- (void)translateSublayersByVectorWithX:(CGFloat)x y:(CGFloat)y;

/**
 * Convenience method to calculate the layer animation parameters needed to transform a rect into another one
 *
 * Be careful: During an animation, the frame of a layer changes. If you set fromRect to layer.frame, this will be
 * the frame of the layer at the time the animation is created, not right before the layer animation is performed. 
 * Those might be the same, but in general this is not the case!
 */
- (void)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

/**
 * Opacity increment or decrement to be applied during the layer animation. Any value between 1.f and -1.f can be provided,
 * though you should ensure that opacity never reaches a value outside [0, 1] during an animation.
 */
- (void)addToOpacity:(CGFloat)opacityIncrement;

@end
