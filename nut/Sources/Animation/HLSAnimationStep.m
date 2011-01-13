//
//  HLSAnimationStep.m
//  nut
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

// Default values as given by Apple UIView documentation
#define ANIMATION_SETTINGS_DEFAULT_DURATION          0.2f
#define ANIMATION_SETTINGS_DEFAULT_DELAY             0.f
#define ANIMATION_SETTINGS_DEFAULT_CURVE             UIViewAnimationCurveEaseInOut

@implementation HLSAnimationStep

#pragma mark Convenience methods

+ (HLSAnimationStep *)animationStep
{
    return [[[[self class] alloc] init] autorelease];
}

+ (HLSAnimationStep *)animationStepMovingView:(UIView *)view fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame
{
    // Convert rectangles from the parent view coordinate system into the window coordinate system
    CGRect beginFrameInWindow = [view.superview convertRect:fromFrame toView:nil];
    CGRect endFrameInWindow = [view.superview convertRect:toFrame toView:nil];
    
    // Scaling matrix
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(endFrameInWindow.size.width / beginFrameInWindow.size.width, 
                                                                  endFrameInWindow.size.height / beginFrameInWindow.size.height);
    
    // Rect centers in the window coordinate system
    CGPoint beginCenterInWindow = CGPointMake(CGRectGetMidX(beginFrameInWindow), CGRectGetMidY(beginFrameInWindow));
    CGPoint endCenterInWindow = CGPointMake(CGRectGetMidX(endFrameInWindow), CGRectGetMidY(endFrameInWindow));
    
    // Translation matrix
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(endCenterInWindow.x - beginCenterInWindow.x, 
                                                                              endCenterInWindow.y - beginCenterInWindow.y);
    
    // Return the resulting animation step
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    animationStep.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    
    return animationStep;    
}

+ (HLSAnimationStep *)animationStepMovingView:(UIView *)view toFrame:(CGRect)toFrame
{
    return [HLSAnimationStep animationStepMovingView:view fromFrame:view.frame toFrame:toFrame];
}

+ (HLSAnimationStep *)animationStepTranslatingView:(UIView *)view
                                            deltaX:(CGFloat)deltaX
                                            deltaY:(CGFloat)deltaY
{
    CGRect toFrame = CGRectMake(view.frame.origin.x + deltaX, 
                                view.frame.origin.y + deltaY, 
                                view.frame.size.width,
                                view.frame.size.height);
    return [HLSAnimationStep animationStepMovingView:view toFrame:toFrame];
}

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        // Default: No change
        self.transform = CGAffineTransformIdentity;
        self.deltaAlpha = 0.f;
        
        // Default animation settings
        self.duration = ANIMATION_SETTINGS_DEFAULT_DURATION;
        self.delay = ANIMATION_SETTINGS_DEFAULT_DELAY;
        self.curve = ANIMATION_SETTINGS_DEFAULT_CURVE;
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize transform = m_transform;

@synthesize deltaAlpha = m_deltaAlpha;

@synthesize duration = m_duration;

@synthesize delay = m_delay;

@synthesize curve = m_curve;

@end
