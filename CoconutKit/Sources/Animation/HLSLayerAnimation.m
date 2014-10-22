//
//  HLSLayerAnimation.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/20/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSLayerAnimation.h"

#import "HLSLogger.h"
#import "HLSObjectAnimation+Friend.h"
#import "HLSVector.h"
#import "NSString+HLSExtensions.h"

/**
 * Just a few important remarks about transforms (CATransform3D and CGAffineTransform):
 *   - transforms are applied on the right: F' = F * T, where F is a frame (this is what CGRectApplyAffineTransform
 *     does). A composed transform T_n * ... * T_2 * T_1 therefore applies T_n first, then T_{n-1}, etc.
 *   - the result of applying a transform using CGRectApplyAffineTransform is not the same as setting the transform
 *     property of a UIView (or CALayer) with the same transform. When applied to the transform property, the result
 *     obtained is relative to the anchor point of the view (resp. layer) and leaves it invariant. When applied to
 *     a frame, the result obtained is relative to the coordinate system in which the frame resides and will in
 *     general move the anchor point
 *   - transforms generated for view / layer animations are meant to be applied on the transform property of a view
 *     (resp. its layer). This has some important consequences when calculating the reverse view or layer animation.
 *     The reverse is namely not simply CATransform3DInvert([self transform]). Since we are applying the changes in
 *     the coordinate system centered on the original view or layer frame, we must do the same when the animation is
 *     played backwards. Therefore, the reverse transform we need is not the inverse of transform = R * S * T, i.e. not
 *     transform^{-1} = T^{-1} * S^{-1} * R^{-1}, but the transform applying the inverse rotation, scaling and
 *     translation transforms, beginning with the operations leaving the frame origin invariant (rotation and scaling),
 *     i.e. transform_{reverse} = T^{-1} * S^{-1} * R^{-1}. This is why rotation, translation and scaling parameters
 *     must be kept separate, so that the reverse animation can be easily computed
 */

@interface HLSLayerAnimation ()

@property (nonatomic, assign) HLSVector4 rotationParameters;
@property (nonatomic, assign) HLSVector3 scaleParameters;
@property (nonatomic, assign) HLSVector3 translationParameters;
@property (nonatomic, assign) HLSVector3 anchorPointTranslationParameters;
@property (nonatomic, assign) HLSVector4 sublayerRotationParameters;
@property (nonatomic, assign) HLSVector3 sublayerScaleParameters;
@property (nonatomic, assign) HLSVector3 sublayerTranslationParameters;
@property (nonatomic, assign) CGFloat sublayerCameraTranslationZ;
@property (nonatomic, assign) CGFloat opacityIncrement;
@property (nonatomic, assign) CGFloat rasterizationScaleIncrement;

@end

@implementation HLSLayerAnimation

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        // Default: No change
        self.rotationParameters = HLSVector4Make(0.f, 1.f, 0.f, 0.f);
        self.scaleParameters = HLSVector3Make(1.f, 1.f, 1.f);
        self.translationParameters = HLSVector3Make(0.f, 0.f, 0.f);
        self.anchorPointTranslationParameters = HLSVector3Make(0.f, 0.f, 0.f);
        
        self.sublayerRotationParameters = HLSVector4Make(0.f, 1.f, 0.f, 0.f);
        self.sublayerScaleParameters = HLSVector3Make(1.f, 1.f, 1.f);
        self.sublayerTranslationParameters = HLSVector3Make(0.f, 0.f, 0.f);
        
        self.sublayerCameraTranslationZ = 0.f;
    }
    return self;
}

#pragma mark Accessors and mutators

- (CATransform3D)transform
{
    CATransform3D transform = [self rotationTransform];
    transform = CATransform3DConcat(transform, [self scaleTransform]);
    return CATransform3DConcat(transform, [self translationTransform]);
}

- (CATransform3D)rotationTransform
{
    return CATransform3DMakeRotation(self.rotationParameters.v1,
                                     self.rotationParameters.v2,
                                     self.rotationParameters.v3,
                                     self.rotationParameters.v4);
}

- (CATransform3D)scaleTransform
{
    return CATransform3DMakeScale(self.scaleParameters.v1,
                                  self.scaleParameters.v2,
                                  self.scaleParameters.v3);
}

- (CATransform3D)translationTransform
{
    return CATransform3DMakeTranslation(self.translationParameters.v1,
                                        self.translationParameters.v2,
                                        self.translationParameters.v3);
}

- (CATransform3D)sublayerTransform
{
    CATransform3D sublayerTransform = [self sublayerRotationTransform];
    sublayerTransform = CATransform3DConcat(sublayerTransform, [self sublayerScaleTransform]);
    sublayerTransform = CATransform3DConcat(sublayerTransform, [self sublayerTranslationTransform]);
    return sublayerTransform;
}

- (CATransform3D)sublayerRotationTransform;
{
    return CATransform3DMakeRotation(self.sublayerRotationParameters.v1,
                                     self.sublayerRotationParameters.v2,
                                     self.sublayerRotationParameters.v3,
                                     self.sublayerRotationParameters.v4);
}

- (CATransform3D)sublayerScaleTransform
{
    return CATransform3DMakeScale(self.sublayerScaleParameters.v1,
                                  self.sublayerScaleParameters.v2,
                                  self.sublayerScaleParameters.v3);
}

- (CATransform3D)sublayerTranslationTransform
{
    return CATransform3DMakeTranslation(self.sublayerTranslationParameters.v1,
                                        self.sublayerTranslationParameters.v2,
                                        self.sublayerTranslationParameters.v3);
}

#pragma mark Convenience methods

- (void)rotateByAngle:(CGFloat)angle aboutVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    self.rotationParameters = HLSVector4Make(angle, x, y, z);
}

- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor zFactor:(CGFloat)zFactor
{
    self.scaleParameters = HLSVector3Make(xFactor, yFactor, zFactor);
}

- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    self.translationParameters = HLSVector3Make(x, y, z);
}

- (void)rotateByAngle:(CGFloat)angle
{
    [self rotateByAngle:angle aboutVectorWithX:0.f y:0.f z:1.f];
}

- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor
{
    [self scaleWithXFactor:xFactor yFactor:yFactor zFactor:1.f];
}

- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y
{
    [self translateByVectorWithX:x y:y z:0.f];
}

- (void)translateAnchorPointByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    self.anchorPointTranslationParameters = HLSVector3Make(x, y, z);
}

- (void)translateAnchorPointByVectorWithX:(CGFloat)x y:(CGFloat)y
{
    [self translateAnchorPointByVectorWithX:x y:y z:0.f];
}

- (void)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    // No rotation required
    self.rotationParameters = HLSVector4Make(0.f, 1.f, 0.f, 0.f);
    
    self.scaleParameters = HLSVector3Make(CGRectGetWidth(toRect) / CGRectGetWidth(fromRect),
                                          CGRectGetHeight(toRect) / CGRectGetHeight(fromRect),
                                          1.f);
    self.translationParameters = HLSVector3Make(CGRectGetMidX(toRect) - CGRectGetMidX(fromRect),
                                                CGRectGetMidY(toRect) - CGRectGetMidY(fromRect),
                                                0.f);
}

- (void)rotateSublayersByAngle:(CGFloat)angle aboutVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    self.sublayerRotationParameters = HLSVector4Make(angle, x, y, z);
}

- (void)scaleSublayersWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor zFactor:(CGFloat)zFactor
{
    self.sublayerScaleParameters = HLSVector3Make(xFactor, yFactor, zFactor);
}

- (void)translateSublayersByVectorWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    self.sublayerTranslationParameters = HLSVector3Make(x, y, z);
}

- (void)rotateSublayersByAngle:(CGFloat)angle
{
    [self rotateSublayersByAngle:angle aboutVectorWithX:0.f y:0.f z:1.f];
}

- (void)scaleSublayersWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor
{
    [self scaleSublayersWithXFactor:xFactor yFactor:yFactor zFactor:1.f];
}

- (void)translateSublayersByVectorWithX:(CGFloat)x y:(CGFloat)y
{
    [self translateSublayersByVectorWithX:x y:y z:0.f];
}

- (void)translateSublayerCameraByVectorWithZ:(CGFloat)z
{    
    self.sublayerCameraTranslationZ = z;
}

- (void)addToOpacity:(CGFloat)opacityIncrement
{
    // Sanitize input
    if (isless(opacityIncrement, -1.f)) {
        HLSLoggerWarn(@"Opacity increment cannot be smaller than -1. Fixed to -1");
        _opacityIncrement = -1.f;
    }
    else if (isgreater(opacityIncrement, 1.f)) {
        HLSLoggerWarn(@"Opacity increment cannot be larger than 1. Fixed to 1");
        _opacityIncrement = 1.f;
    }
    else {
        _opacityIncrement = opacityIncrement;
    }
}

- (void)addToRasterizationScale:(CGFloat)rasterizationScaleIncrement
{
    self.rasterizationScaleIncrement = rasterizationScaleIncrement;
}

#pragma mark Reverse animation

- (id)reverseObjectAnimation
{
    // See remarks at the beginning
    HLSLayerAnimation *reverseLayerAnimation = [super reverseObjectAnimation];
    
    [reverseLayerAnimation rotateByAngle:-self.rotationParameters.v1
                        aboutVectorWithX:self.rotationParameters.v2
                                       y:self.rotationParameters.v3
                                       z:self.rotationParameters.v4];
    [reverseLayerAnimation scaleWithXFactor:1.f / self.scaleParameters.v1
                                    yFactor:1.f / self.scaleParameters.v2
                                    zFactor:1.f / self.scaleParameters.v3];
    [reverseLayerAnimation translateByVectorWithX:-self.translationParameters.v1
                                                y:-self.translationParameters.v2
                                                z:-self.translationParameters.v3];
    [reverseLayerAnimation translateAnchorPointByVectorWithX:-self.anchorPointTranslationParameters.v1
                                                           y:-self.anchorPointTranslationParameters.v2
                                                           z:-self.anchorPointTranslationParameters.v3];
    
    [reverseLayerAnimation rotateSublayersByAngle:-self.sublayerRotationParameters.v1
                                 aboutVectorWithX:self.sublayerRotationParameters.v2
                                                y:self.sublayerRotationParameters.v3
                                                z:self.sublayerRotationParameters.v4];
    [reverseLayerAnimation scaleSublayersWithXFactor:1.f / self.sublayerScaleParameters.v1
                                             yFactor:1.f / self.sublayerScaleParameters.v2
                                             zFactor:1.f / self.sublayerScaleParameters.v3];
    [reverseLayerAnimation translateSublayersByVectorWithX:-self.sublayerTranslationParameters.v1
                                                         y:-self.sublayerTranslationParameters.v2
                                                         z:-self.sublayerTranslationParameters.v3];
    [reverseLayerAnimation translateSublayerCameraByVectorWithZ:-self.sublayerCameraTranslationZ];
    
    reverseLayerAnimation.opacityIncrement = -self.opacityIncrement;
    reverseLayerAnimation.togglingShouldRasterize = self.togglingShouldRasterize;
    reverseLayerAnimation.rasterizationScaleIncrement = -self.rasterizationScaleIncrement;
    return reverseLayerAnimation;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSLayerAnimation *layerAnimationCopy = [super copyWithZone:zone];
    
    layerAnimationCopy.rotationParameters = self.rotationParameters;
    layerAnimationCopy.scaleParameters = self.scaleParameters;
    layerAnimationCopy.translationParameters = self.translationParameters;
    layerAnimationCopy.anchorPointTranslationParameters = self.anchorPointTranslationParameters;
    
    layerAnimationCopy.sublayerRotationParameters = self.sublayerRotationParameters;
    layerAnimationCopy.sublayerScaleParameters = self.sublayerScaleParameters;
    layerAnimationCopy.sublayerTranslationParameters = self.sublayerTranslationParameters;
    layerAnimationCopy.sublayerCameraTranslationZ = self.sublayerCameraTranslationZ;
    
    layerAnimationCopy.opacityIncrement = self.opacityIncrement;
    layerAnimationCopy.togglingShouldRasterize = self.togglingShouldRasterize;
    layerAnimationCopy.rasterizationScaleIncrement = self.rasterizationScaleIncrement;
    return layerAnimationCopy;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; rotationParamers: %@; scaleParameters: %@; translationParameters: %@; "
            "opacityIncrement: %.2f; sublayerCameraTranslationZ: %.2f; rasterizationScaleIncrement: %.2f>",
            [self class],
            self,
            HLSStringFromVector4(self.rotationParameters),
            HLSStringFromVector3(self.scaleParameters),
            HLSStringFromVector3(self.translationParameters),
            self.opacityIncrement,
            self.sublayerCameraTranslationZ,
            self.rasterizationScaleIncrement];
}

@end
