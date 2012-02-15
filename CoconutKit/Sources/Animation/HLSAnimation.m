//
//  HLSAnimation.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimation.h"

#import "HLSAssert.h"
#import "HLSConverters.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSUserInterfaceLock.h"

#import <QuartzCore/QuartzCore.h>

@interface HLSAnimation ()

@property (nonatomic, retain) NSArray *animationSteps;
@property (nonatomic, retain) NSEnumerator *animationStepsEnumerator;
@property (nonatomic, retain) HLSAnimationStep *currentAnimationStep;
@property (nonatomic, assign, getter=isRunning) BOOL running;

- (void)playStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated;

- (void)playNextStepAnimated:(BOOL)animated;

- (NSArray *)reverseAnimationSteps;

- (void)animationStepDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation HLSAnimation

#pragma mark Class methods

+ (HLSAnimation *)animationWithAnimationSteps:(NSArray *)animationSteps
{
    return [[[[self class] alloc] initWithAnimationSteps:animationSteps] autorelease];
}

+ (HLSAnimation *)animationWithAnimationStep:(HLSAnimationStep *)animationStep
{
    NSArray *animationSteps = nil;
    if (animationStep) {
        animationSteps = [NSArray arrayWithObject:animationStep];
    }
    else {
        animationSteps = [NSArray array];
    }
    return [HLSAnimation animationWithAnimationSteps:animationSteps];
}

#pragma mark Object creation and destruction

- (id)initWithAnimationSteps:(NSArray *)animationSteps
{
    HLSAssertObjectsInEnumerationAreKindOfClass(animationSteps, HLSAnimationStep);
    if ((self = [super init])) {
        if (! animationSteps) {
            self.animationSteps = [NSArray array];
        }
        else {
            self.animationSteps = animationSteps;
        }
        self.resizeViews = NO;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.animationSteps = nil;
    self.animationStepsEnumerator = nil;
    self.currentAnimationStep = nil;
    self.tag = nil;
    self.userInfo = nil;
    self.delegate = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize animationSteps = m_animationSteps;

@synthesize animationStepsEnumerator = m_animationStepsEnumerator;

@synthesize currentAnimationStep = m_currentAnimationStep;

@synthesize tag = m_tag;

@synthesize userInfo = m_userInfo;

@synthesize resizeViews = m_resizeViews;

@synthesize lockingUI = m_lockingUI;

@synthesize bringToFront = m_bringToFront;

@synthesize running = m_running;

@synthesize delegate = m_delegate;

#pragma mark Animation

- (void)playAnimated:(BOOL)animated
{
    // Cannot be played if already running (equivalently, we can test we are iterating over steps)
    if (self.animationStepsEnumerator) {
        HLSLoggerDebug(@"The animation is already running");
        return;
    }
    
    // Lock the UI during the animation
    if (self.lockingUI) {
        [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    }
    
    m_animated = animated;
    
    if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
        [self.delegate animationWillStart:self animated:m_animated];
    }
    
    self.running = YES;
    m_cancelling = NO;
    
    // Begin with the first step
    [self playNextStepAnimated:animated];
}

- (void)playStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    // If duration is 0, do not create an animation block; creating such useless animation blocks might cause flickering
    // in animations
    if (animated && ! doubleeq(animationStep.duration, 0.f)) {
        [UIView beginAnimations:nil context:animationStep];
        
        [UIView setAnimationDuration:animationStep.duration];
        [UIView setAnimationCurve:animationStep.curve];
        
        // Remark: The selector names animationWillStart:context: and animationDidStop:finished:context: (though appearing
        //         in the UIKit UIView header documentation) are reserved by Apple. Using them might lead to app rejection!
        [UIView setAnimationDidStopSelector:@selector(animationStepDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];        
    }
    
    // Animate all views in the animation step
    for (UIView *view in [animationStep views]) {
        // The views are brought to the front in the order they were registered with the animation step
        if (self.bringToFront) {
            [view.superview bringSubviewToFront:view];
        }
        
        HLSViewAnimationStep *viewAnimationStep = [animationStep viewAnimationStepForView:view];
        NSAssert(viewAnimationStep != nil, @"Missing animation step; data consistency failure");
        
        // Alpha always between 0.f and 1.f
        CGFloat alpha = view.alpha + viewAnimationStep.alphaVariation;
        if (floatlt(alpha, -1.f)) {
            HLSLoggerWarn(@"Animation steps adding to value larger than -1 for view %@. Fixed to -1, but your animation is incorrect", view);
            view.alpha = -1.f;
        }
        else if (floatgt(alpha, 1.f)) {
            HLSLoggerWarn(@"Animation steps adding to value larger than 1 for view %@. Fixed to 1, but your animation is incorrect", view);
            view.alpha = 1.f;
        }
        else {
            view.alpha = alpha;
        }
        
        // In all cases, the transform has to be applied on the view center. This requires a conversion in the coordinate system of
        // centered on the view.
        
        // Alter frame
        if (self.resizeViews) {
            // Only affine translation or scale transforms are allowed
            if (! CATransform3DIsAffine(viewAnimationStep.transform)) {
                HLSLoggerWarn(@"Animations with resizeViews set to YES only support affine transforms");
                continue;
            }
            
            CGAffineTransform affineTransform = CATransform3DGetAffineTransform(viewAnimationStep.transform);            
            if (! floateq(affineTransform.b, 0.f) || ! floateq(affineTransform.c, 0.f)) {
                HLSLoggerWarn(@"Animations with resizeViews set to YES only support translation or scale transforms");
                continue;
            }
            
            CGAffineTransform translation = CGAffineTransformMakeTranslation(-view.center.x, -view.center.y);
            CGAffineTransform convTransform = CGAffineTransformConcat(CGAffineTransformConcat(translation, affineTransform), 
                                                                      CGAffineTransformInvert(translation));
            
            // TODO: This does not resize subviews correctly. Maybe that is not possible?
            view.frame = CGRectApplyAffineTransform(view.frame, convTransform);
        }
        // Alter transform
        else {
            CATransform3D translation = CATransform3DMakeTranslation(-view.transform.tx, -view.transform.ty, 0.f);
            CATransform3D convTransform = CATransform3DConcat(CATransform3DConcat(translation, viewAnimationStep.transform), 
                                                              CATransform3DInvert(translation));
            view.layer.transform = CATransform3DConcat(view.layer.transform, convTransform);
        }
    }
    
    // Animated
    if (animated && ! doubleeq(animationStep.duration, 0.f)) {
        [UIView commitAnimations];
        
        // The code will resume in the animationDidStop:finished:context: method
    }
    // Instantaneous
    else {
        // Notify the end of the animation
        if (! m_cancelling) {
            if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
                [self.delegate animationStepFinished:animationStep animated:m_animated];
            }            
        }
        
        [self playNextStepAnimated:animated];
    }
}

- (void)playNextStepAnimated:(BOOL)animated
{
    // First call?
    if (! self.animationStepsEnumerator) {
        self.animationStepsEnumerator = [self.animationSteps objectEnumerator];
    }
    
    // Proceeed with the next step (if any)
    self.currentAnimationStep = [self.animationStepsEnumerator nextObject];
    if (self.currentAnimationStep) {
        [self playStep:self.currentAnimationStep animated:animated];
    }
    // Done with the animation
    else {
        self.animationStepsEnumerator = nil;
        
        // Unlock the UI
        if (self.lockingUI) {
            [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
        }
        
        self.running = NO;
        
        if (! m_cancelling) {
            if ([self.delegate respondsToSelector:@selector(animationDidStop:animated:)]) {
                [self.delegate animationDidStop:self animated:m_animated];
            }            
        }
    }    
}

- (void)cancel
{
    if (! self.running) {
        HLSLoggerInfo(@"The animation is not running, nothing to cancel");
        return;
    }
    
    if (m_cancelling) {
        HLSLoggerInfo(@"The animation is already being cancelled");
        return;
    }
    
    m_cancelling = YES;
    
    // Cancel all animations
    for (UIView *view in [self.currentAnimationStep views]) {
        [view.layer removeAllAnimations];
    }
    
    // Play all remaining steps without animation
    [self playNextStepAnimated:NO];
}

#pragma mark Creating the reverse animation

- (HLSAnimation *)reverseAnimation
{
    NSArray *reverseAnimationSteps = [self reverseAnimationSteps];
    HLSAnimation *reverseAnimation = [HLSAnimation animationWithAnimationSteps:reverseAnimationSteps];
    reverseAnimation.tag = [NSString stringWithFormat:@"reverse_%@", self.tag];
    reverseAnimation.resizeViews = self.resizeViews;
    reverseAnimation.lockingUI = self.lockingUI;
    reverseAnimation.bringToFront = self.bringToFront;
    reverseAnimation.delegate = self.delegate;
    
    return reverseAnimation;
}

- (NSArray *)reverseAnimationSteps
{
    if (! self.animationSteps) {
        return nil;
    }
    
    // Reverse all animation steps
    NSMutableArray *reverseAnimationSteps = [NSMutableArray array];
    for (HLSAnimationStep *animationStep in [self.animationSteps reverseObjectEnumerator]) {
        HLSAnimationStep *reverseAnimationStep = [HLSAnimationStep animationStep];
        
        // Reverse the associated view animation steps
        for (UIView *view in [animationStep views]) {
            HLSViewAnimationStep *viewAnimationStep = [animationStep viewAnimationStepForView:view];
            [reverseAnimationStep addViewAnimationStep:[viewAnimationStep reverseViewAnimationStep] forView:view];
        }
        
        // Animation step properties
        reverseAnimationStep.duration = animationStep.duration;
        switch (animationStep.curve) {
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
        
        [reverseAnimationSteps addObject:reverseAnimationStep];
    }
    
    return [NSArray arrayWithArray:reverseAnimationSteps];
}

#pragma mark Animation callbacks

- (void)animationStepDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (m_cancelling) {
        return;
    }
    
    if (! m_cancelling) {
        if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
            HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
            [self.delegate animationStepFinished:animationStep animated:m_animated];
        }        
    }
    
    [self playNextStepAnimated:m_animated];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; animationSteps: %@; tag: %@; lockingUI: %@, bringToFront: %@, delegate: %p>", 
            [self class],
            self,
            self.animationSteps,
            self.tag,
            HLSStringFromBool(self.lockingUI),
            HLSStringFromBool(self.bringToFront),
            self.delegate];
}

@end
