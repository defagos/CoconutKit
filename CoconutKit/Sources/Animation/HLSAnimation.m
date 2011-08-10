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

@interface HLSAnimation ()

@property (nonatomic, retain) NSArray *animationSteps;
@property (nonatomic, retain) NSEnumerator *animationStepsEnumerator;
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
    if (animationSteps) {
        animationSteps = [NSArray arrayWithObject:animationStep];
    }
    else {
        animationSteps = [NSArray array];
    }
    return [HLSAnimation animationWithAnimationSteps:animationSteps];
}

#pragma mark Object creation and destruction

- (id)initWithAnimationSteps:(NSArray *)animationSteps;
{
    HLSAssertObjectsInEnumerationAreKindOfClass(animationSteps, HLSAnimationStep);
    if ((self = [super init])) {
        if (! animationSteps) {
            self.animationSteps = [NSArray array];
        }
        else {
            self.animationSteps = animationSteps;
        }
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
    self.tag = nil;
    self.userInfo = nil;
    self.delegate = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize animationSteps = m_animationSteps;

@synthesize animationStepsEnumerator = m_animationStepsEnumerator;

@synthesize tag = m_tag;

@synthesize userInfo = m_userInfo;

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
        
        // The fact that transform is a property is essential. If you "po" a UIView in gdb, you will see something like:
        //   <UIView: 0x4d57c40; frame = (141 508; 136 102); transform = [1, 0, 0, 1, 30, -60]; autoresize = RM+BM; layer = <CALayer: 0x4d57cc0>>
        // i.e. the view is attached a transform, not applied a transform which would get lost after it has been applied. If
        // we already have a transform which is applied, we therefore need to compose it with the transform we are applying during
        // the step
        view.transform = CGAffineTransformConcat(viewAnimationStep.transform, view.transform);
    }
    
    // Animated
    if (animated && ! doubleeq(animationStep.duration, 0.f)) {
        [UIView commitAnimations];
        
        // The code will resume in the animationDidStop:finished:context: method
    }
    // Instantaneous
    else {
        // Notify the end of the animation
        if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
            [self.delegate animationStepFinished:animationStep animated:m_animated];
        }
        
        [self playNextStepAnimated:animated];
    }
}

- (void)playNextStepAnimated:(BOOL)animated
{
    // First call?
    if (! self.animationStepsEnumerator) {
        self.animationStepsEnumerator = [self.animationSteps objectEnumerator];
        m_firstStep = YES;
    }
    
    // Proceeed with the next step (if any)
    HLSAnimationStep *nextAnimationStep = [self.animationStepsEnumerator nextObject];
    if (nextAnimationStep) {
        [self playStep:nextAnimationStep animated:animated];
    }
    // Done with the animation
    else {
        self.animationStepsEnumerator = nil;
        
        // Unlock the UI
        if (self.lockingUI) {
            [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
        }
        
        self.running = NO;
        
        if ([self.delegate respondsToSelector:@selector(animationDidStop:animated:)]) {
            [self.delegate animationDidStop:self animated:m_animated];
        }
    }    
}

#pragma mark Creating the reverse animation

- (HLSAnimation *)reverseAnimation
{
    NSArray *reverseAnimationSteps = [self reverseAnimationSteps];
    HLSAnimation *reverseAnimation = [HLSAnimation animationWithAnimationSteps:reverseAnimationSteps];
    reverseAnimation.tag = [NSString stringWithFormat:@"reverse_%@", self.tag];
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
            
            // Create the reverse view animation step
            HLSViewAnimationStep *reverseViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
            reverseViewAnimationStep.transform = CGAffineTransformInvert(viewAnimationStep.transform);
            reverseViewAnimationStep.alphaVariation = -viewAnimationStep.alphaVariation;
            
            [reverseAnimationStep addViewAnimationStep:reverseViewAnimationStep forView:view];
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
    HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
    
    if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
        [self.delegate animationStepFinished:animationStep animated:m_animated];
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
