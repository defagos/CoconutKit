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
#define ANIMATION_STEP_DEFAULT_DURATION          0.2
#define ANIMATION_STEP_DEFAULT_DELAY             0.
#define ANIMATION_STEP_DEFAULT_CURVE             UIViewAnimationCurveEaseInOut

@implementation HLSAnimationStep

#pragma mark Convenience methods

+ (HLSAnimationStep *)animationStep
{
    return [[[[self class] alloc] init] autorelease];
}

+ (HLSAnimationStep *)animationStepIdentityForView:(UIView *)view
{
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    animationStep.duration = 0.;
    animationStep.alpha = view.alpha;
    
    return animationStep;
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
        m_alpha = ANIMATION_STEP_ALPHA_NOT_SET;
        
        // Default animation settings
        self.duration = ANIMATION_STEP_DEFAULT_DURATION;
        self.delay = ANIMATION_STEP_DEFAULT_DELAY;
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

@synthesize alpha = m_alpha;

- (void)setAlpha:(CGFloat)alpha
{
    // Sanitize input
    if (floateq(alpha, ANIMATION_STEP_ALPHA_NOT_SET)) {
        m_alpha = alpha;
    }
    else if (floatlt(alpha, 0.f)) {
        logger_warn(@"alpha must be >= 0. Fixed to 0");
        m_alpha = 0.f;
    }
    else if (floatgt(alpha, 1.f)) {
        logger_warn(@"alpha must be <= 1. Fixed to 1");
        m_alpha = 1.f;
    }
    else {
        m_alpha = alpha;
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

@synthesize delay = m_delay;

- (void)setDelay:(NSTimeInterval)delay
{
    // Sanitize input
    if (doublelt(delay, 0.)) {
        logger_warn(@"Delay must be non-negative. Fixed to 0");
        m_delay = 0.;
    }
    else {
        m_delay = delay;
    }
}

@synthesize curve = m_curve;

@synthesize tag = m_tag;

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    // Deep copy
    HLSAnimationStep *animationStep = [[[[self class] allocWithZone:zone] init] autorelease];
    animationStep.transform = self.transform;
    animationStep.alpha = self.alpha;
    animationStep.duration = self.duration;
    animationStep.delay = self.delay;
    animationStep.curve = self.curve;
    animationStep.tag = [self.tag copy];
    
    return animationStep;
}

@end
