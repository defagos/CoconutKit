//
//  HLSViewAnimationStep.m
//  nut
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewAnimationStep.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSTransform.h"

static const CGFloat kAnimationStepDefaultAlphaVariation = 0.f;

@implementation HLSViewAnimationStep

#pragma mark Convenience methods

+ (HLSViewAnimationStep *)viewAnimationStep
{
    return [[[[self class] alloc] init] autorelease];
}

+ (HLSViewAnimationStep *)viewAnimationStepAnimatingViewFromFrame:(CGRect)fromFrame 
                                                          toFrame:(CGRect)toFrame
{
    return [HLSViewAnimationStep viewAnimationStepAnimatingViewFromFrame:fromFrame
                                                                 toFrame:toFrame 
                                                      withAlphaVariation:0.f];
}

+ (HLSViewAnimationStep *)viewAnimationStepAnimatingViewFromFrame:(CGRect)fromFrame
                                                          toFrame:(CGRect)toFrame
                                               withAlphaVariation:(CGFloat)alphaVariation
{
    // Return the resulting animation step
    HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep.transform = [HLSTransform transformFromRect:fromFrame toRect:toFrame];
    viewAnimationStep.alphaVariation = alphaVariation;
    return viewAnimationStep;    
}

+ (HLSViewAnimationStep *)viewAnimationStepTranslatingViewWithDeltaX:(CGFloat)deltaX
                                                              deltaY:(CGFloat)deltaY
{
    return [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:deltaX
                                                                     deltaY:deltaY
                                                             alphaVariation:0.f];
}

+ (HLSViewAnimationStep *)viewAnimationStepTranslatingViewWithDeltaX:(CGFloat)deltaX
                                                              deltaY:(CGFloat)deltaY
                                                      alphaVariation:(CGFloat)alphaVariation
{
    HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep.transform = CGAffineTransformMakeTranslation(deltaX, deltaY);
    viewAnimationStep.alphaVariation = alphaVariation;
    return viewAnimationStep;
}

+ (HLSViewAnimationStep *)viewAnimationStepUpdatingViewWithTransform:(CGAffineTransform)transform
                                                      alphaVariation:(CGFloat)alphaVariation
{
    HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep.transform = transform;
    viewAnimationStep.alphaVariation = alphaVariation;
    return viewAnimationStep;
}

+ (HLSViewAnimationStep *)viewAnimationStepUpdatingViewWithAlphaVariation:(CGFloat)alphaVariation
{
    HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep.alphaVariation = alphaVariation;
    return viewAnimationStep;
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Default: No change
        self.transform = CGAffineTransformIdentity;
        self.alphaVariation = kAnimationStepDefaultAlphaVariation;  
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize transform = m_transform;

@synthesize alphaVariation = m_alphaVariation;

- (void)setAlphaVariation:(CGFloat)alphaVariation
{
    // Sanitize input
    if (floatlt(alphaVariation, -1.f)) {
        logger_warn(@"Alpha variation cannot be smaller than -1. Fixed to -1");
        m_alphaVariation = -1.f;
    }
    else if (floatgt(alphaVariation, 1.f)) {
        logger_warn(@"Alpha variation cannot be larger than 1. Fixed to 1");
        m_alphaVariation = 1.f;
    }
    else {
        m_alphaVariation = alphaVariation;
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; transform: %@; alphaVariation: %f>", 
            [self class],
            self,
            NSStringFromCGAffineTransform(self.transform),
            self.alphaVariation];
}

@end
