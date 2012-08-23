//
//  HLSViewAnimation.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewAnimation.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSObjectAnimation+Friend.h"
#import "NSString+HLSExtensions.h"

/**
 * Just a few important remarks about transforms (CATransform3D and CGAffineTransform):
 *   - transforms are applied on the right: F' = F * T, where F is a frame (this is what CGRectApplyAffineTransform 
 *     does). A composed transform F_n * ... * F_2 * F_1 therefore applies F_1 first, then F_2, etc.
 *   - the result of applying a transform using CGRectApplyAffineTransform is not the same as setting the transform
 *     property of a UIView (or CALayer) with the same transform. When applied to the transform property, the result
 *     obtained is relative to the anchor point of the view (resp. layer) and leaves it invariant. When applied to 
 *     a frame, the result obtained is relative to the coordinate system in which the frame resides and will in
 *     general move the frame anchor point
 *   - transforms generated for view / layer animations are meant to be applied on the transform property of a view
 *     (resp. its layer). This has some important consequences when calculating the reverse view or layer animation.
 *     The reverse is namely not simply CATransform3DInvert([self transform]). Since we are applying the changes in 
 *     the coordinate system centered on the original view or layer frame, we must do the same when the animation is 
 *     played backwards. Therefore, the reverse transform we need is not the inverse of transform = T * S * R, i.e. not 
 *     transform^{-1} = R^{-1} * S^{-1} * T^{-1}, but the transform applying the inverse rotation, scaling and 
 *     translation transforms, beginning with the operations leaving the frame origin invariant (rotation and scaling), 
 *     i.e. transform_{reverse} = R^{-1} * S^{-1} * T^{-1}. This is why rotation, translation and scaling parameters 
 *     must be kept separate, so that the reverse animation can be easily computed
 */

@interface HLSViewAnimation ()

@property (nonatomic, assign) HLSVector2 scaleParameters;
@property (nonatomic, assign) HLSVector2 translationParameters;

- (CGAffineTransform)scaleTransform;
- (CGAffineTransform)translationTransform;

@end

@implementation HLSViewAnimation

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Default: No change
        self.scaleParameters = HLSVector2Make(1.f, 1.f);
        self.translationParameters = HLSVector2Make(0.f, 0.f);
        
        self.alphaVariation = 0.f;
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize scaleParameters = m_scaleParameters;

@synthesize translationParameters = m_translationParameters;

- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor
{
    self.scaleParameters = HLSVector2Make(xFactor, yFactor);
}

- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y
{
    self.translationParameters = HLSVector2Make(x, y);
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

- (CGAffineTransform)transform
{
    return CGAffineTransformConcat([self scaleTransform], [self translationTransform]);
}

- (CGAffineTransform)scaleTransform
{
    return CGAffineTransformMakeScale(self.scaleParameters.v1, self.scaleParameters.v2);
}

- (CGAffineTransform)translationTransform
{
    return CGAffineTransformMakeTranslation(self.translationParameters.v1, self.translationParameters.v2);
}

#pragma mark Convenience methods

- (void)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    self.scaleParameters = HLSVector2Make(CGRectGetWidth(toRect) / CGRectGetWidth(fromRect),
                                          CGRectGetHeight(toRect) / CGRectGetHeight(fromRect));
    self.translationParameters = HLSVector2Make(CGRectGetMidX(toRect) - CGRectGetMidX(fromRect),
                                                CGRectGetMidY(toRect) - CGRectGetMidY(fromRect));
}

#pragma mark Reverse animation

- (id)reverseObjectAnimation
{
    // See remarks at the beginning
    HLSViewAnimation *reverseViewAnimation = [super reverseObjectAnimation];
    [reverseViewAnimation scaleWithXFactor:1.f / self.scaleParameters.v1
                                   yFactor:1.f / self.scaleParameters.v2];
    [reverseViewAnimation translateByVectorWithX:-self.translationParameters.v1
                                               y:-self.translationParameters.v2];
    reverseViewAnimation.alphaVariation = -self.alphaVariation;
    return reverseViewAnimation;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSViewAnimation *viewAnimationCopy = [super copyWithZone:zone];
    viewAnimationCopy.scaleParameters = self.scaleParameters;
    viewAnimationCopy.translationParameters = self.translationParameters;
    viewAnimationCopy.alphaVariation = self.alphaVariation;
    return viewAnimationCopy;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; transform: %@; alphaVariation: %f>", 
            [self class],
            self,
            NSStringFromCGAffineTransform([self transform]),
            self.alphaVariation];
}

@end
