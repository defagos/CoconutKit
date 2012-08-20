//
//  HLSLayerAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/20/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLayerAnimationStep.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

/**
 * Just a few important remarks about transforms (CATransform3D and CGAffineTransform):
 *   - transforms are applied on the right: F' = F * T, where F is a frame (this is what CGRectApplyAffineTransform
 *     does). A composed transform F_n * ... * F_2 * F_1 therefore applies F_1 first, then F_2, etc.
 *   - the result of applying a transform using CGRectApplyAffineTransform is not the same as setting the transform
 *     property of a UIView (or CALayer) with the same transform. When applied to the transform property, the result
 *     obtained is relative to the center of the view (resp. layer) and leaves its center invariant. When applied to
 *     a frame, the result obtained is relative to the coordinate system in which the frame resides and will in
 *     general move the frame center
 *   - transforms generated for view animation steps are meant to be applied on the transform property of a view
 *     (or of its layer). This has some important consequences when calculating the reverse view animation step.
 *     The inverse is namely not simply CATransform3DInvert([self transform]). Since we are applying the changes in
 *     the coordinate system centered on the original view frame, we must do the same when the animation is played
 *     backwards. Therefore, the reverse transform we need is not the inverse of transform = T * S * R, i.e. not
 *     transform^{-1} = R^{-1} * S^{-1} * T^{-1}, but the transform applying the inverse rotation, scaling and
 *     translation transforms, beginning with the operations leaving the frame origin invariant (rotation and scaling),
 *     i.e. transform_{reverse} = R^{-1} * S^{-1} * T^{-1}. This is why rotation, translation and scaling parameters
 *     must be kept separate, so that the reverse animation can be easily computed. This has some drawbacks (some
 *     animations are not possible, e.g. translation first, then rotation), but is far easier to understand and
 *     implement correctly.
 */

static const CGFloat kAnimationStepDefaultAlphaVariation = 0.f;

@interface HLSLayerAnimationStep ()

@property (nonatomic, assign) HLSVector4 rotationParameters;
@property (nonatomic, assign) HLSVector3 scaleParameters;
@property (nonatomic, assign) HLSVector3 translationParameters;

- (CATransform3D)rotationTransform;
- (CATransform3D)scaleTransform;
- (CATransform3D)translationTransform;

@end

@implementation HLSLayerAnimationStep

#pragma mark Convenience methods

+ (HLSLayerAnimationStep *)layerAnimationStep
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Default: No change
        self.rotationParameters = HLSVector4Make(0.f, 1.f, 0.f, 0.f);
        self.scaleParameters = HLSVector3Make(1.f, 1.f, 1.f);
        self.translationParameters = HLSVector3Make(0.f, 0.f, 0.f);
        
        self.alphaVariation = kAnimationStepDefaultAlphaVariation;
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize rotationParameters = m_rotationParameters;

@synthesize scaleParameters = m_scaleParameters;

@synthesize translationParameters = m_translationParameters;

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

@synthesize alphaVariation = m_alphaVariation;

- (void)setAlphaVariation:(CGFloat)alphaVariation
{
    // Sanitize input
    if (floatlt(alphaVariation, -1.f)) {
        HLSLoggerWarn(@"Alpha variation cannot be smaller than -1. Fixed to -1");
        m_alphaVariation = -1.f;
    }
    else if (floatgt(alphaVariation, 1.f)) {
        HLSLoggerWarn(@"Alpha variation cannot be larger than 1. Fixed to 1");
        m_alphaVariation = 1.f;
    }
    else {
        m_alphaVariation = alphaVariation;
    }
}

@dynamic transform;

- (CATransform3D)transform
{
    CATransform3D transform = [self rotationTransform];
    transform = CATransform3DConcat(transform, [self scaleTransform]);
    return CATransform3DConcat(transform, [self translationTransform]);
}

- (CATransform3D)rotationTransform
{
    return CATransform3DMakeRotation(self.rotationParameters.v1, self.rotationParameters.v2, self.rotationParameters.v3, self.rotationParameters.v4);
}

- (CATransform3D)scaleTransform
{
    return CATransform3DMakeScale(self.scaleParameters.v1, self.scaleParameters.v2, self.scaleParameters.v3);
}

- (CATransform3D)translationTransform
{
    return CATransform3DMakeTranslation(self.translationParameters.v1, self.translationParameters.v2, self.translationParameters.v3);
}

#pragma mark Convenience methods

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

#pragma mark Reverse animation

- (HLSLayerAnimationStep *)reverseLayerAnimationStep
{
    // See remarks at the beginning
    HLSLayerAnimationStep *reverseLayerAnimationStep = [HLSLayerAnimationStep layerAnimationStep];
    [reverseLayerAnimationStep rotateByAngle:-self.rotationParameters.v1
                            aboutVectorWithX:self.rotationParameters.v2
                                           y:self.rotationParameters.v3
                                           z:self.rotationParameters.v4];
    [reverseLayerAnimationStep scaleWithXFactor:1.f / self.scaleParameters.v1
                                        yFactor:1.f / self.scaleParameters.v2
                                        zFactor:1.f / self.scaleParameters.v3];
    [reverseLayerAnimationStep translateByVectorWithX:-self.translationParameters.v1
                                                    y:-self.translationParameters.v2
                                                    z:-self.translationParameters.v3];
    reverseLayerAnimationStep.alphaVariation = -self.alphaVariation;
    return reverseLayerAnimationStep;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSLayerAnimationStep *layerAnimationStepCopy = [[HLSLayerAnimationStep allocWithZone:zone] init];
    layerAnimationStepCopy.rotationParameters = self.rotationParameters;
    layerAnimationStepCopy.scaleParameters = self.scaleParameters;
    layerAnimationStepCopy.translationParameters = self.translationParameters;
    layerAnimationStepCopy.alphaVariation = self.alphaVariation;
    return layerAnimationStepCopy;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; transform: %@; alphaVariation: %f>",
            [self class],
            self,
            HLSStringFromCATransform3D([self transform]) ,
            self.alphaVariation];
}

@end
