//
//  HLSViewAnimation.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSViewAnimation.h"

#import "HLSLogger.h"
#import "HLSObjectAnimation+Friend.h"
#import "HLSVector.h"
#import "NSString+HLSExtensions.h"

/**
 * Please read the remarks at the top of HLSLayerAnimation.m
 */

@interface HLSViewAnimation ()

@property (nonatomic, assign) HLSVector2 scaleParameters;
@property (nonatomic, assign) HLSVector2 translationParameters;
@property (nonatomic, assign) CGFloat alphaIncrement;

@end

@implementation HLSViewAnimation

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        // Default: No change
        self.scaleParameters = HLSVector2Make(1.f, 1.f);
        self.translationParameters = HLSVector2Make(0.f, 0.f);
    }
    return self;
}

#pragma mark Accessors and mutators

- (void)addToAlpha:(CGFloat)alphaIncrement
{
    // Sanitize input
    if (isless(alphaIncrement, -1.f)) {
        HLSLoggerWarn(@"Alpha increment cannot be smaller than -1. Fixed to -1");
        _alphaIncrement = -1.f;
    }
    else if (isgreater(alphaIncrement, 1.f)) {
        HLSLoggerWarn(@"Alpha variation cannot be larger than 1. Fixed to 1");
        _alphaIncrement = 1.f;
    }
    else {
        _alphaIncrement = alphaIncrement;
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

- (void)scaleWithXFactor:(CGFloat)xFactor yFactor:(CGFloat)yFactor
{
    self.scaleParameters = HLSVector2Make(xFactor, yFactor);
}

- (void)translateByVectorWithX:(CGFloat)x y:(CGFloat)y
{
    self.translationParameters = HLSVector2Make(x, y);
}

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
    reverseViewAnimation.alphaIncrement = -self.alphaIncrement;
    return reverseViewAnimation;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSViewAnimation *viewAnimationCopy = [super copyWithZone:zone];
    viewAnimationCopy.scaleParameters = self.scaleParameters;
    viewAnimationCopy.translationParameters = self.translationParameters;
    viewAnimationCopy.alphaIncrement = self.alphaIncrement;
    return viewAnimationCopy;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; scaleParameters: %@; translationParameters: %@; alphaIncrement: %.2f>", 
            [self class],
            self,
            HLSStringFromVector2(self.scaleParameters),
            HLSStringFromVector2(self.translationParameters),
            self.alphaIncrement];
}

@end
