//
//  HLSViewAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimationStep.h"

#import "HLSAnimationStep+Protected.h"

@implementation HLSViewAnimationStep

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.curve = UIViewAnimationCurveEaseInOut;   
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize curve = m_curve;

#pragma mark View animations

- (void)addViewAnimation:(HLSViewAnimation *)viewAnimation forView:(UIView *)view
{
    [self addObjectAnimation:viewAnimation forObject:view];
}

#pragma mark Managing the animation

- (void)playAnimated:(BOOL)animated
{
    for (UIView *view in [self objects]) {
        HLSViewAnimation *viewAnimation = (HLSViewAnimation *)[self objectAnimationForObject:view];
        NSAssert(viewAnimation != nil, @"Missing view animation; data consistency failure");
        
        // Alpha animation (alpha must always lie between 0.f and 1.f)
        CGFloat alpha = view.alpha + viewAnimation.alphaVariation;
        if (floatlt(alpha, -1.f)) {
            HLSLoggerWarn(@"View animations adding to an alpha value larger than -1 for view %@. Fixed to -1, but your animation is incorrect", view);
            alpha = -1.f;
        }
        else if (floatgt(alpha, 1.f)) {
            HLSLoggerWarn(@"View animations adding to an alpha value larger than 1 for view %@. Fixed to 1, but your animation is incorrect", view);
            alpha = 1.f;
        }
        
        view.alpha = alpha;
        
        // Animate frame
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(-view.center.x, -view.center.y);
        CGAffineTransform convTransform = CGAffineTransformConcat(CGAffineTransformConcat(translationTransform, viewAnimation.transform),
                                                                  CGAffineTransformInvert(translationTransform));
        view.frame = CGRectApplyAffineTransform(view.frame, convTransform);
        
        // Ensure better subview resizing in some cases (e.g. UISearchBar)
        [view layoutIfNeeded];
    }
}

- (void)cancelAnimations
{
    for (UIView *view in [self objects]) {
        [view.layer removeAllAnimations];
    }
}

#pragma mark Reverse animation

- (id)reverseAnimationStep
{
    HLSViewAnimationStep *reverseAnimationStep = [super reverseAnimationStep];
    switch (self.curve) {
        case UIViewAnimationCurveEaseIn:
            reverseAnimationStep.curve = UIViewAnimationCurveEaseOut;
            break;
            
        case UIViewAnimationCurveEaseOut:
            reverseAnimationStep.curve = UIViewAnimationCurveEaseIn;
            break;
            
        case UIViewAnimationCurveLinear:
        case UIViewAnimationCurveEaseInOut:
        default:
            // Nothing to do
            break;
    }
    return reverseAnimationStep;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSViewAnimationStep *animationStepCopy = [super copyWithZone:zone];
    animationStepCopy.curve = self.curve;
    return animationStepCopy;
}

@end
