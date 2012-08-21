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
#import "HLSZeroingWeakRef.h"
#import "NSString+HLSExtensions.h"

#import <QuartzCore/QuartzCore.h>

@interface HLSAnimation ()

@property (nonatomic, retain) NSArray *animationSteps;
@property (nonatomic, retain) NSEnumerator *animationStepsEnumerator;
@property (nonatomic, retain) HLSAnimationStep *currentAnimationStep;
@property (nonatomic, retain) UIView *dummyView;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isCancelling) BOOL cancelling;
@property (nonatomic, assign, getter=isTerminating) BOOL terminating;
@property (nonatomic, retain) HLSZeroingWeakRef *delegateZeroingWeakRef;

- (void)playAnimationStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated;
- (void)playViewAnimationStep:(HLSViewAnimationStep *)viewAnimationStep animated:(BOOL)animated;
- (void)playLayerAnimationStep:(HLSLayerAnimationStep *)layerAnimationStep animated:(BOOL)animated;

- (void)playNextAnimationStepAnimated:(BOOL)animated;

- (void)animationDidStart:(CAAnimation *)animation;
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag;

- (void)animationStepWillStart:(NSString *)animationID context:(void *)context;
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
        
        // This dummy view fixes an issue encountered with animation blocks: If no view is altered
        // during an animation block, the block duration is reduced to 0. To prevent this, we create
        // and animate a dummy invisible view in each animation step, so that the duration is never
        // reduced to 0
        self.dummyView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [[UIApplication sharedApplication].keyWindow addSubview:self.dummyView];
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
    [self.dummyView removeFromSuperview];
    self.dummyView = nil;
    self.delegateZeroingWeakRef = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize animationSteps = m_animationSteps;

@synthesize animationStepsEnumerator = m_animationStepsEnumerator;

@synthesize currentAnimationStep = m_currentAnimationStep;

@synthesize tag = m_tag;

@synthesize userInfo = m_userInfo;

@synthesize dummyView = m_dummyView;

@synthesize lockingUI = m_lockingUI;

@synthesize running = m_running;

@synthesize cancelling = m_cancelling;

@synthesize terminating = m_terminating;

@synthesize delegateZeroingWeakRef = m_delegateZeroingWeakRef;

@dynamic delegate;

- (id<HLSAnimationDelegate>)delegate
{
    return self.delegateZeroingWeakRef.object;
}

- (void)setDelegate:(id<HLSAnimationDelegate>)delegate
{
    self.delegateZeroingWeakRef = [[[HLSZeroingWeakRef alloc] initWithObject:delegate] autorelease];
    [self.delegateZeroingWeakRef addCleanupAction:@selector(cancel) onTarget:self];
}

- (NSTimeInterval)duration
{
    NSTimeInterval duration = 0.;
    for (HLSAnimationStep *animationStep in self.animationSteps) {
        duration += animationStep.duration;
    }
    return duration;
}

#pragma mark Animation

- (void)playAnimated:(BOOL)animated
{
    // Cannot be played if already running
    if (self.running) {
        HLSLoggerDebug(@"The animation is already running");
        return;
    }
    
    self.running = YES;
    self.cancelling = NO;
    self.terminating = NO;
    
    m_animated = animated;
    
    // Lock the UI during the animation
    if (self.lockingUI) {
        [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    }
    
    // Begin with the first step
    [self playNextAnimationStepAnimated:animated];
}

- (void)playAfterDelay:(NSTimeInterval)delay
{
    if (floatlt(delay, 0.)) {
        m_delay = 0.;
        HLSLoggerWarn(@"Negative delay. Fixed to 0");
    }
    else {
        m_delay = delay;
    }
    
    [self playAnimated:YES];
}

- (void)playAnimationStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    // UIView block-based animation
    if ([animationStep isKindOfClass:[HLSViewAnimationStep class]]) {
        HLSViewAnimationStep *viewAnimationStep = (HLSViewAnimationStep *)animationStep;
        [self playViewAnimationStep:viewAnimationStep animated:animated];
    }
    // Core Animation
    else if ([animationStep isKindOfClass:[HLSLayerAnimationStep class]]) {
        HLSLayerAnimationStep *layerAnimationStep = (HLSLayerAnimationStep *)animationStep;
        [self playLayerAnimationStep:layerAnimationStep animated:animated];
    }
    else {
        HLSLoggerError(@"Unsupported animation step class");
    }
}

- (void)playViewAnimationStep:(HLSViewAnimationStep *)viewAnimationStep animated:(BOOL)animated
{
    // If duration is 0, do not create an animation block; creating such useless animation blocks might cause flickering
    // in animations
    BOOL actuallyAnimated = animated && ! doubleeq(viewAnimationStep.duration, 0.f);
    if (actuallyAnimated) {
        [UIView beginAnimations:nil context:viewAnimationStep];
        
        [UIView setAnimationDuration:viewAnimationStep.duration];
        [UIView setAnimationCurve:viewAnimationStep.curve];
        [UIView setAnimationDelay:m_delay];
        
        // The delay is just used for the first step. Set it to 0 for the remaining ones
        m_delay = 0.;
        
        // Remark: The selector names animationWillStart:context: and animationDidStop:finished:context:, though appearing
        //         in the UIKit UIView header documentation, are reserved by Apple. Using them might lead to app rejection!
        [UIView setAnimationWillStartSelector:@selector(animationStepWillStart:context:)];
        [UIView setAnimationDidStopSelector:@selector(animationStepDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    // Instantaneous
    else {
        // First step
        if ([self.animationSteps indexOfObject:viewAnimationStep] == 0) {
            if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
                [self.delegate animationWillStart:self animated:animated];
            }
        }
    }
    
    [viewAnimationStep playAnimated:actuallyAnimated];
    
    // Animate the dummy view
    self.dummyView.alpha = 1.f - self.dummyView.alpha;
    
    // Animated
    if (actuallyAnimated) {
        [UIView commitAnimations];
        
        // The code will resume in the animationDidStop:finished:context: method
    }
    // Instantaneous
    else {
        // Notify the end of the animation step. Use m_animated, not simply NO (so that animation steps with duration 0 and
        // played with animated = YES are still notified as animated)
        if (! self.cancelling) {
            if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
                [self.delegate animationStepFinished:viewAnimationStep animated:self.terminating ? NO : m_animated];
            }
        }
        
        [self playNextAnimationStepAnimated:animated];
    }
}

- (void)playLayerAnimationStep:(HLSLayerAnimationStep *)layerAnimationStep animated:(BOOL)animated
{
    // If duration is 0, do not create an animation block; creating such useless animation blocks might cause flickering
    // in animations
    BOOL actuallyAnimated = animated && ! doubleeq(layerAnimationStep.duration, 0.f);
    if (actuallyAnimated) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:layerAnimationStep.duration];
        [CATransaction setAnimationTimingFunction:layerAnimationStep.timingFunction];
        
        // TODO: Delay and timing function (curve)
        
        // The delay is just used for the first step. Set it to 0 for the remaining ones
        m_delay = 0.;
    }
    // Instantaneous
    else {
        // First step
        if ([self.animationSteps indexOfObject:layerAnimationStep] == 0) {
            if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
                [self.delegate animationWillStart:self animated:animated];
            }
        }
    }
    
    [layerAnimationStep playAnimated:actuallyAnimated];
    
    // Animate the dummy view. It is also used to set a delegate (one for all animations in the transaction)
    // which will receive the start / end animation events
    if (actuallyAnimated) {
        CABasicAnimation *dummyViewOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        dummyViewOpacityAnimation.fromValue = [NSNumber numberWithFloat:self.dummyView.alpha];
        dummyViewOpacityAnimation.toValue = [NSNumber numberWithFloat:1.f - self.dummyView.alpha];
        dummyViewOpacityAnimation.delegate = self;
        [dummyViewOpacityAnimation setValue:layerAnimationStep forKey:@"animationStep"];
        [self.dummyView.layer addAnimation:dummyViewOpacityAnimation forKey:nil];
    }
    self.dummyView.alpha = 1.f - self.dummyView.alpha;
    
    // Animated
    if (actuallyAnimated) {
        [CATransaction commit];
    }
    // Instantaneous
    else {
        // Notify the end of the animation step. Use m_animated, not simply NO (so that animation steps with duration 0 and
        // played with animated = YES are still notified as animated)
        if (! self.cancelling) {
            if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
                [self.delegate animationStepFinished:layerAnimationStep animated:self.terminating ? NO : m_animated];
            }
        }
        
        [self playNextAnimationStepAnimated:animated];
    }
}

- (void)playNextAnimationStepAnimated:(BOOL)animated
{
    // First call?
    if (! self.animationStepsEnumerator) {
        self.animationStepsEnumerator = [self.animationSteps objectEnumerator];
    }
    
    // Proceeed with the next step (if any)
    self.currentAnimationStep = [self.animationStepsEnumerator nextObject];
    if (self.currentAnimationStep) {
        [self playAnimationStep:self.currentAnimationStep animated:animated];
    }
    // Done with the animation
    else {
        // Empty animation must still call the animationWillStart:animated delegate method
        if ([self.animationSteps count] == 0) {
            if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
                [self.delegate animationWillStart:self animated:animated];
            }
        }
        
        self.animationStepsEnumerator = nil;
        
        // Unlock the UI
        if (self.lockingUI) {
            [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
        }
        
        self.running = NO;
        
        if (! self.cancelling) {
            if ([self.delegate respondsToSelector:@selector(animationDidStop:animated:)]) {
                [self.delegate animationDidStop:self animated:self.terminating ? NO : animated];
            }
        }
        
        // If the animation has been cancelled and was not played animated, update
        // its status. If the animation was played animated, the end animation callback
        // will still be called for the interrupted animation step, and we must update
        // the animation status there (it would be too early here)
        if (animated) {
            self.cancelling = NO;
            self.terminating = NO;
        }
    }
}

- (void)cancel
{
    if (! self.running) {
        HLSLoggerDebug(@"The animation is not running, nothing to cancel");
        return;
    }
    
    if (self.cancelling || self.terminating) {
        HLSLoggerDebug(@"The animation is already being cancelled or terminated");
        return;
    }
    
    self.cancelling = YES;
    
    // Cancel all animations
    [self.currentAnimationStep cancelAnimations];
    
    // Play all remaining steps without animation
    [self playNextAnimationStepAnimated:NO];
}

- (void)terminate
{
    if (! self.running) {
        HLSLoggerDebug(@"The animation is not running, nothing to terminate");
        return;
    }
    
    if (self.cancelling || self.terminating) {
        HLSLoggerDebug(@"The animation is already being cancelled or terminated");
        return;
    }
    
    self.terminating = YES;
    
    if (self.currentAnimationStep) {
        // Cancel all animations
        [self.currentAnimationStep cancelAnimations];
        
        // The animation callback will be called, but to get delegate events in the proper order we cannot
        // notify that the animation step has ended there. We must do it right now, and not anymore
        // in -animationStepDidStop:finished:context:
        if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
            [self.delegate animationStepFinished:self.currentAnimationStep animated:NO];
        }
    }
    
    // Play all remaining steps without animation
    [self playNextAnimationStepAnimated:NO];
}

#pragma mark Creating animations variants from an existing animation

- (HLSAnimation *)animationWithDuration:(NSTimeInterval)duration
{
    if (doublelt(duration, 0.f)) {
        HLSLoggerError(@"The duration cannot be negative");
        return nil;
    }
    
    HLSAnimation *animation = [[self copy] autorelease];
    
    // Find out which factor must be applied to each animation step to preserve the animation appearance for the
    // specified duration
    double factor = duration / [self duration];
    
    // Distribute the total duration evenly among animation steps
    for (HLSAnimationStep *animationStep in animation.animationSteps) {
        animationStep.duration *= factor;
    }
    
    return animation;
}

- (HLSAnimation *)reverseAnimation
{
    HLSAnimation *reverseAnimation = nil;
    if (self.animationSteps) {
        NSMutableArray *reverseAnimationSteps = [NSMutableArray array];
        for (HLSAnimationStep *animationStep in [self.animationSteps reverseObjectEnumerator]) {
            [reverseAnimationSteps addObject:[animationStep reverseAnimationStep]];
        }
        reverseAnimation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:reverseAnimationSteps]];
    }
    else {
        reverseAnimation = [HLSAnimation animationWithAnimationStep:nil];
    }
    
    reverseAnimation.tag = [self.tag isFilled] ? [NSString stringWithFormat:@"reverse_%@", self.tag] : nil;
    reverseAnimation.lockingUI = self.lockingUI;
    reverseAnimation.delegate = self.delegate;
    
    return reverseAnimation;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSAnimation *animationCopy = nil;
    if (self.animationSteps) {
        NSMutableArray *animationStepCopies = [NSMutableArray array];
        for (HLSAnimationStep *animationStep in self.animationSteps) {
            HLSAnimationStep *animationStepCopy = [[animationStep copyWithZone:zone] autorelease];
            [animationStepCopies addObject:animationStepCopy];
        }
        animationCopy = [[HLSAnimation allocWithZone:zone] initWithAnimationSteps:[NSMutableArray arrayWithArray:animationStepCopies]];
    }
    else {
        animationCopy = [[HLSAnimation allocWithZone:zone] initWithAnimationSteps:nil];
    }
    
    animationCopy.tag = self.tag;
    animationCopy.lockingUI = self.lockingUI;
    animationCopy.delegate = self.delegate;
    animationCopy.userInfo = [NSDictionary dictionaryWithDictionary:self.userInfo];
    
    return animationCopy;
}

#pragma mark Animation callbacks

// TODO: UIView-based callbacks too!

- (void)animationStepDidStart:(HLSAnimationStep *)animationStep
{
    // This callback is still called when an animation is cancelled before it actually started (i.e. if a delay has been
    // set). Do not notify the delegate in such cases
    if (! self.cancelling) {
        // Notify just before the execution of the first step (if a delay has been set, this event is not fired until the
        // delay period is over, as for UIView animation blocks)
        if ([self.animationSteps indexOfObject:animationStep] == 0) {
            if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
                [self.delegate animationWillStart:self animated:YES];
            }
        }
    }
}

- (void)animationStepDidStop:(HLSAnimationStep *)animationStep
{
    if (self.cancelling) {
        self.cancelling = NO;
        return;
    }
    
    if (self.terminating) {
        self.terminating = NO;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
        [self.delegate animationStepFinished:animationStep animated:m_animated];
    }
    
    [self playNextAnimationStepAnimated:m_animated];
}

- (void)animationDidStart:(CAAnimation *)animation
{
    HLSAnimationStep *animationStep = [animation valueForKey:@"animationStep"];
    [self animationStepDidStart:animationStep];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    HLSAnimationStep *animationStep = [animation valueForKey:@"animationStep"];
    [self animationStepDidStop:animationStep];
}

- (void)animationStepWillStart:(NSString *)animationID context:(void *)context
{
    HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
    [self animationStepDidStart:animationStep];
}

- (void)animationStepDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
    [self animationStepDidStop:animationStep];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; animationSteps: %@; tag: %@; lockingUI: %@; delegate: %p>",
            [self class],
            self,
            self.animationSteps,
            self.tag,
            HLSStringFromBool(self.lockingUI),
            self.delegate];
}

@end
