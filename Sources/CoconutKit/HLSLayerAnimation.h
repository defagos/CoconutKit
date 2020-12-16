//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSObjectAnimation.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
 * on autoresizing properties on iOS
 *
 * Since the layer transform is animated, none of the -[CALayer layoutSublayers] or -[UIView layoutSublayersOfLayer:] 
 * methods need to be implemented for HLSLayerAnimation-based animations.
 *
 * In general, and if you do not need to animate view frames to resize subviews during animations, you should
 * use layer animations instead of view animations since they have far more capabilities.
 */
@interface HLSLayerAnimation : HLSObjectAnimation

/**
 * Create a layer animation step with default settings
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

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
 *
 * Remark: x and y are in relative coordinates. Refer to the -[CALayer anchorPoint] documentation for more information
 */
- (void)translateAnchorPointByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)translateAnchorPointByVectorWithX:(CGFloat)x y:(CGFloat)y;

/**
 * Geometric transform parameters to be applied to sublayers during the layer animation
 */
- (void)rotateSublayersByAngle:(CGFloat)angle aboutVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)scaleSublayersWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor zFactor:(CGFloat)zFactor;
- (void)translateSublayersByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;

/**
 * Move the position of the camera from which sublayers are seen. The usual position is (0, 0, 0), which
 * means no perspective is applied (the sublayers are seen from infinity, i.e. z = infinity). Providing 
 * a non-zero meaningful value for z (usually some factor of the layer or screen dimensions) applies a 
 * 3D perspective to sublayers
 */
- (void)translateSublayerCameraByVectorWithZ:(CGFloat)z;

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
 * though you should ensure that opacity never reaches a value outside [0, 1] during the course of an animation.
 */
- (void)addToOpacity:(CGFloat)opacityIncrement;

/**
 * Whether the shouldRasterize flag should be changed during the animation
 */
@property (nonatomic, getter=isTogglingShouldRasterize) BOOL togglingShouldRasterize;

/**
 * Rasterization scale increment or decrement to be applied during the layer animation. You can use this parameter
 * to pixelize layers (small rasterization scale value) or to give them a blurry appearance (medium values)
 */
- (void)addToRasterizationScale:(CGFloat)rasterizationScaleIncrement;

@end

NS_ASSUME_NONNULL_END
