//
//  HLSViewAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSViewAnimationStep.h"

#import "CALayer+HLSExtensions.h"
#import "HLSAnimationStep+Friend.h"
#import "HLSAnimationStep+Protected.h"
#import "HLSLogger.h"
#import "HLSViewAnimation+Friend.h"

@interface HLSViewAnimationStep ()

@property (nonatomic, strong) UIView *dummyView;

@end

@implementation HLSViewAnimationStep

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.curve = UIViewAnimationCurveEaseInOut;        
    }
    return self;
}

#pragma mark Managing the animation

- (void)addViewAnimation:(HLSViewAnimation *)viewAnimation forView:(UIView *)view
{
    [self addObjectAnimation:viewAnimation forObject:view];
}

- (void)playAnimationWithStartTime:(NSTimeInterval)startTime animated:(BOOL)animated
{
    // UIView animation blocks create Core Animations internally, but those are immutable. We cannot therefore
    // tweak those animations to implement start time support, and there is sadly no way to do it at the
    // UIView block level
    
    if (animated) {
        // This dummy view fixes an issue encountered with animation blocks: If no view is altered
        // during an animation block, the block duration is reduced to 0. To prevent this, we create
        // and animate a dummy invisible view in each animation step, so that the duration is never
        // reduced to 0
        self.dummyView = [[UIView alloc] initWithFrame:CGRectZero];
        [[UIApplication sharedApplication].keyWindow addSubview:self.dummyView];
        
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:self.duration];
        [UIView setAnimationCurve:self.curve];
        
        // Remark: The selector names animationWillStart:context: and animationDidStop:finished:context:, though appearing
        //         in the UIKit UIView header documentation, are reserved by Apple. Using them might lead to app rejection!
        [UIView setAnimationDidStopSelector:@selector(animationStepDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    
    for (UIView *view in [self objects]) {
        HLSViewAnimation *viewAnimation = (HLSViewAnimation *)[self objectAnimationForObject:view];
        NSAssert(viewAnimation != nil, @"Missing view animation; data consistency failure");
        
        // Alpha animation (alpha must always lie between 0.f and 1.f)
        CGFloat alpha = view.alpha + viewAnimation.alphaIncrement;
        if (isless(alpha, -1.f)) {
            HLSLoggerWarn(@"View animations adding to an alpha value larger than -1 for view %@. Fixed to -1, but your animation is incorrect", view);
            alpha = -1.f;
        }
        else if (isgreater(alpha, 1.f)) {
            HLSLoggerWarn(@"View animations adding to an alpha value larger than 1 for view %@. Fixed to 1, but your animation is incorrect", view);
            alpha = 1.f;
        }
        
        view.alpha = alpha;
        
        // Animate the frame. The transform has to be applied on the view center. This requires a conversion in the coordinate system
        // centered on the view
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(-view.center.x, -view.center.y);
        CGAffineTransform convTransform = CGAffineTransformConcat(CGAffineTransformConcat(translationTransform, viewAnimation.transform),
                                                                  CGAffineTransformInvert(translationTransform));
        view.frame = CGRectApplyAffineTransform(view.frame, convTransform);
        
        // Ensure better subview resizing in some cases (e.g. UISearchBar)
        [view layoutIfNeeded];
    }
        
    if (animated) {
        // Animate the dummy view
        self.dummyView.alpha = 1.f - self.dummyView.alpha;
        
        [UIView commitAnimations];
        
        // The code will resume in the animationDidStop:finished:context: method
    }
}

- (void)pauseAnimation
{
    for (UIView *view in [self objects]) {
        [view.layer pauseAllAnimations];
    }
    [self.dummyView.layer pauseAllAnimations];
}

- (void)resumeAnimation
{
    for (UIView *view in [self objects]) {
        [view.layer resumeAllAnimations];
    }
    [self.dummyView.layer resumeAllAnimations];
}

- (BOOL)isAnimationPaused
{
    return [self.dummyView.layer isPaused];
}

- (void)terminateAnimation
{
    // We must recursively cancel subview animations (this is especially important since altering the frame (e.g.
    // by scaling it) seems to create additional implicit animations, which still finish and trigger their end
    // animation callback with finished = YES!)
    for (UIView *view in [self objects]) {
        [view.layer removeAllAnimationsRecursively];
    }
    [self.dummyView.layer removeAllAnimationsRecursively];
}

- (NSTimeInterval)elapsedTime
{
    // Since start time support cannot be implemented for UIView animations (see comment in -playAnimationWithStartTime:animated),
    // we must not provide any elapsed time information. The elapsed time is namely used to start an animation again at a precise
    // location, but this is not possible here
    return self.duration;
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

- (void)animationStepDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.dummyView removeFromSuperview];
    self.dummyView = nil;
    
    [self notifyAsynchronousAnimationStepDidStopFinished:[finished boolValue]];
}

@end
