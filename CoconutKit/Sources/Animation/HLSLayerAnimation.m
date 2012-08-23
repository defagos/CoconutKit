//
//  HLSLayerAnimation.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/20/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLayerAnimation.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSObjectAnimation+Friend.h"
#import "NSString+HLSExtensions.h"

/**
 * Please read the remarks at the top of HLSViewAnimation.m
 */

@interface HLSLayerAnimation ()

@property (nonatomic, assign) HLSVector4 rotationParameters;
@property (nonatomic, assign) HLSVector3 scaleParameters;
@property (nonatomic, assign) HLSVector3 translationParameters;

- (CATransform3D)rotationTransform;
- (CATransform3D)scaleTransform;
- (CATransform3D)translationTransform;

@end

@implementation HLSLayerAnimation

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Default: No change
        self.rotationParameters = HLSVector4Make(0.f, 1.f, 0.f, 0.f);
        self.scaleParameters = HLSVector3Make(1.f, 1.f, 1.f);
        self.translationParameters = HLSVector3Make(0.f, 0.f, 0.f);
        
        self.opacityVariation = 0.f;
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

@synthesize opacityVariation = m_opacityVariation;

- (void)setOpacityVariation:(CGFloat)opacityVariation
{
    // Sanitize input
    if (floatlt(opacityVariation, -1.f)) {
        HLSLoggerWarn(@"Opacity variation cannot be smaller than -1. Fixed to -1");
        m_opacityVariation = -1.f;
    }
    else if (floatgt(opacityVariation, 1.f)) {
        HLSLoggerWarn(@"Opacity variation cannot be larger than 1. Fixed to 1");
        m_opacityVariation = 1.f;
    }
    else {
        m_opacityVariation = opacityVariation;
    }
}

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
    reverseLayerAnimation.opacityVariation = -self.opacityVariation;
    return reverseLayerAnimation;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSLayerAnimation *layerAnimationCopy = [super copyWithZone:zone];
    layerAnimationCopy.rotationParameters = self.rotationParameters;
    layerAnimationCopy.scaleParameters = self.scaleParameters;
    layerAnimationCopy.translationParameters = self.translationParameters;
    layerAnimationCopy.opacityVariation = self.opacityVariation;
    return layerAnimationCopy;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; transform: %@; opacityVariation: %f>",
            [self class],
            self,
            HLSStringFromCATransform3D([self transform]) ,
            self.opacityVariation];
}

@end
