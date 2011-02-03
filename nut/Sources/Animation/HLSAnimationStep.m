//
//  HLSAnimationStep.m
//  nut
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

// Default values as given by Apple UIView documentation
#define ANIMATION_STEP_DEFAULT_DURATION                 0.2
#define ANIMATION_STEP_DEFAULT_ALPHA_VARIATION          0.f
#define ANIMATION_STEP_DEFAULT_CURVE                    UIViewAnimationCurveEaseInOut

@implementation HLSAnimationStep

#pragma mark Convenience methods

+ (HLSAnimationStep *)animationStep
{
    return [[[[self class] alloc] init] autorelease];
}

+ (HLSAnimationStep *)animationStepAnimatingViewFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame
{
    // Scaling matrix
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(toFrame.size.width / fromFrame.size.width, 
                                                                  toFrame.size.height / fromFrame.size.height);
    
    // Rect centers in the parent view coordinate system
    CGPoint beginCenterInParent = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMidY(fromFrame));
    CGPoint endCenterInParent = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame));
    
    // Translation matrix
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(endCenterInParent.x - beginCenterInParent.x, 
                                                                              endCenterInParent.y - beginCenterInParent.y);
    
    // Return the resulting animation step
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    animationStep.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    
    return animationStep;    
}

+ (HLSAnimationStep *)animationStepTranslatingViewWithDeltaX:(CGFloat)deltaX
                                                      deltaY:(CGFloat)deltaY
{
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    animationStep.transform = CGAffineTransformMakeTranslation(deltaX, deltaY);
    return animationStep;
}

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        // Default: No change
        self.transform = CGAffineTransformIdentity;
        self.alphaVariation = ANIMATION_STEP_DEFAULT_ALPHA_VARIATION;
        
        // Default animation settings
        self.duration = ANIMATION_STEP_DEFAULT_DURATION;
        self.curve = ANIMATION_STEP_DEFAULT_CURVE;   
    }
    return self;
}

- (void)dealloc
{
    self.tag = nil;
    [super dealloc];
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

@synthesize duration = m_duration;

- (void)setDuration:(NSTimeInterval)duration
{
    // Sanitize input
    if (doublelt(duration, 0.)) {
        logger_warn(@"Duration must be non-negative. Fixed to 0");
        m_duration = 0.;
    }
    else {
        m_duration = duration;
    }
}

@synthesize curve = m_curve;

@synthesize tag = m_tag;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; transform: %@; alphaVariation: %f; duration: %f; tag: %@>", 
            [self class],
            self,
            NSStringFromCGAffineTransform(self.transform),
            self.alphaVariation,
            self.duration,
            self.tag];
}

@end
