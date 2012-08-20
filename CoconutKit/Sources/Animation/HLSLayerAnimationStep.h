//
//  HLSLayerAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/20/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSVector.h"

/**
 * A layer animation step describes the changes applied to a layer during an animation step (HLSAnimationStep). An
 * animation step is the combination of several layer and / or view animation steps (HLSLayerAnimationStep, 
 * HLSViewAnimationStep) applied to a set of views and layers, and represent the collective set of changes applied 
 * to them during some time interval. An animation (HLSAnimation) is then simply a collection of animation steps.
 *
 * Designated initializer: init (create a layer animation step with default settings)
 * NSCopying behavior: Deep copy
 */
@interface HLSLayerAnimationStep : NSObject <NSCopying> {
@private
    HLSVector4 m_rotationParameters;
    HLSVector3 m_scaleParameters;
    HLSVector3 m_translationParameters;
    CGFloat m_alphaVariation;
}

/**
 * Identity layer animation step
 */
+ (HLSLayerAnimationStep *)layerAnimationStep;

/**
 * Geometric transform parameters to be applied during the layer animation step. The resulting transform (which you can
 * obtained by calling -transform) applies the rotation, the scale and finally the translation
 *
 * Remark: Since you cannot control the order of the rotation, scaling and translation transforms, some animations
 *         are not supported (e.g. translating, then rotating). The currently supported animations should cover most
 *         needs, though
 */
- (void)rotateByAngle:(CGFloat)angle aboutVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor zFactor:(CGFloat)zFactor;
- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;

/**
 * Convenience method to calculate the view animation step parameters needed to transform a rect into another one
 */
- (void)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

/**
 * Alpha increment or decrement to be applied during the layer animation step. Any value between 1.f and -1.f can be provided,
 * though you should ensure that alphas never add to a value outside [0, 1] during an animation.
 * Default value is 0.f
 */
@property (nonatomic, assign) CGFloat alphaVariation;

/**
 * The transform corresponding to the transform parameters associated with the layer animation step
 */
@property (nonatomic, readonly, assign) CATransform3D transform;

/**
 * Return the inverse view animation step
 */
- (HLSLayerAnimationStep *)reverseLayerAnimationStep;

@end
