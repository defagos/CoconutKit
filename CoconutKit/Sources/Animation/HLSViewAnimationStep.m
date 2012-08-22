//
//  HLSViewAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimationStep.h"

#import "HLSAnimationStep+Protected.h"

@interface HLSViewAnimationStep ()

@property (nonatomic, retain) UIView *dummyView;

- (void)animationStepWillStart:(NSString *)animationID context:(void *)context;
- (void)animationStepDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation HLSViewAnimationStep

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.curve = UIViewAnimationCurveEaseInOut;
        
        // This dummy view fixes an issue encountered with animation blocks: If no view is altered
        // during an animation block, the block duration is reduced to 0. To prevent this, we create
        // and animate a dummy invisible view in each animation step, so that the duration is never
        // reduced to 0
        self.dummyView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [[UIApplication sharedApplication].keyWindow addSubview:self.dummyView];
    }
    return self;
}

- (void)dealloc
{
    [self.dummyView removeFromSuperview];
    self.dummyView = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize curve = m_curve;

@synthesize dummyView = m_dummyView;

#pragma mark Managing the animation

- (void)addViewAnimation:(HLSViewAnimation *)viewAnimation forView:(UIView *)view
{
    [self addObjectAnimation:viewAnimation forObject:view];
}

- (void)playAfterDelay:(NSTimeInterval)delay withDelegate:(id<HLSAnimationStepDelegate>)delegate animated:(BOOL)animated
{
    // If duration is 0, do not create an animation block; creating such useless animation blocks might cause flickering
    // in animations
    BOOL actuallyAnimated = animated && ! doubleeq(self.duration, 0.f);
    if (actuallyAnimated) {
        [UIView beginAnimations:nil context:delegate];
        
        [UIView setAnimationDuration:self.duration];
        [UIView setAnimationCurve:self.curve];
        [UIView setAnimationDelay:delay];
        
        // Remark: The selector names animationWillStart:context: and animationDidStop:finished:context:, though appearing
        //         in the UIKit UIView header documentation, are reserved by Apple. Using them might lead to app rejection!
        [UIView setAnimationWillStartSelector:@selector(animationStepWillStart:context:)];
        [UIView setAnimationDidStopSelector:@selector(animationStepDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    // Instantaneous
    else {
        // Still report the animated value, even if not actually animated
        [delegate animationStepWillStart:self animated:animated];
    }
    
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
    
    // Animate the dummy view
    self.dummyView.alpha = 1.f - self.dummyView.alpha;
    
    // Animated
    if (actuallyAnimated) {
        [UIView commitAnimations];
        
        // The code will resume in the animationDidStop:finished:context: method
    }
    // Instantaneous
    else {
        // Still report the animated value, even if not actually animated
        [delegate animationStepDidStop:self animated:animated];
    }
}

- (void)cancel
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

#pragma mark Animation delegate methods

- (void)animationStepWillStart:(NSString *)animationID context:(void *)context
{
    id<HLSAnimationStepDelegate> delegate = context;
    [delegate animationStepWillStart:self animated:YES];
}

- (void)animationStepDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    id<HLSAnimationStepDelegate> delegate = context;
    [delegate animationStepDidStop:self animated:YES];
}

@end
