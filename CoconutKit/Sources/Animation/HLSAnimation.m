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

- (void)playStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated;

- (void)playNextStepAnimated:(BOOL)animated;

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

@synthesize resizeViews = m_resizeViews;

@synthesize dummyView = m_dummyView;

@synthesize lockingUI = m_lockingUI;

@synthesize bringToFront = m_bringToFront;

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
    [self playNextStepAnimated:animated];
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

- (void)playStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    // If duration is 0, do not create an animation block; creating such useless animation blocks might cause flickering
    // in animations
    if (animated && ! doubleeq(animationStep.duration, 0.f)) {
        [UIView beginAnimations:nil context:animationStep];
        
        [UIView setAnimationDuration:animationStep.duration];
        [UIView setAnimationCurve:animationStep.curve];
        [UIView setAnimationDelay:m_delay];
        
        // The delay is just used for the first step. Set it to 0 for the remaining ones
        m_delay = 0.;
        
        // Remark: The selector names animationWillStart:context: and animationDidStop:finished:context: (though appearing
        //         in the UIKit UIView header documentation) are reserved by Apple. Using them might lead to app rejection!
        [UIView setAnimationWillStartSelector:@selector(animationStepWillStart:context:)];
        [UIView setAnimationDidStopSelector:@selector(animationStepDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    // Instantaneous
    else {
        // First step
        if ([self.animationSteps indexOfObject:animationStep] == 0) {
            if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
                [self.delegate animationWillStart:self animated:animated];
            }        
        }
    }
    
    // Animate the dummy view
    self.dummyView.alpha = 1.f - self.dummyView.alpha;
    
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
        
        // In all cases, the transform has to be applied on the view center. This requires a conversion in the coordinate system
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
            
            // TODO: This does not resize subviews correctly in all cases. Maybe that is not possible?
            view.frame = CGRectApplyAffineTransform(view.frame, convTransform);
            
            // Ensure better subview resizing in some cases (e.g. UISearchBar)
            [view layoutIfNeeded];
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
        // Notify the end of the animation step. Use m_animated, not simply NO (so that animation steps with duration 0 and
        // played with animated = YES are still notified as animated)
        if (! self.cancelling) {
            if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
                [self.delegate animationStepFinished:animationStep animated:self.terminating ? NO : m_animated];
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
        HLSLoggerInfo(@"The animation is not running, nothing to cancel");
        return;
    }
    
    if (self.cancelling || self.terminating) {
        HLSLoggerInfo(@"The animation is already being cancelled or terminated");
        return;
    }
    
    self.cancelling = YES;
    
    // Cancel all animations
    for (UIView *view in [self.currentAnimationStep views]) {
        [view.layer removeAllAnimations];
    }
    
    // Play all remaining steps without animation
    [self playNextStepAnimated:NO];
}

- (void)terminate
{
    if (! self.running) {
        HLSLoggerInfo(@"The animation is not running, nothing to terminate");
        return;
    }
    
    if (self.cancelling || self.terminating) {
        HLSLoggerInfo(@"The animation is already being cancelled or terminated");
        return;
    }
    
    self.terminating = YES;
    
    if (self.currentAnimationStep) {
        // Cancel all animations
        for (UIView *view in [self.currentAnimationStep views]) {
            [view.layer removeAllAnimations];
        }
        
        // The animation callback will be called, but to get delegate events in the proper order we cannot
        // notify that the animation step has ended there. We must do it right now, and not anymore
        // in -animationStepDidStop:finished:context:
        if ([self.delegate respondsToSelector:@selector(animationStepFinished:animated:)]) {
            [self.delegate animationStepFinished:self.currentAnimationStep animated:NO];
        }
    }
        
    // Play all remaining steps without animation
    [self playNextStepAnimated:NO];
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
    reverseAnimation.resizeViews = self.resizeViews;
    reverseAnimation.lockingUI = self.lockingUI;
    reverseAnimation.bringToFront = self.bringToFront;
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
            [animationStepCopies addObject:[animationStep copyWithZone:zone]];
        }
        animationCopy = [[HLSAnimation allocWithZone:zone] initWithAnimationSteps:[NSMutableArray arrayWithArray:animationStepCopies]];
    }
    else {
        animationCopy = [[HLSAnimation allocWithZone:zone] initWithAnimationSteps:nil];
    }
    
    animationCopy.tag = self.tag;
    animationCopy.resizeViews = self.resizeViews;
    animationCopy.lockingUI = self.lockingUI;
    animationCopy.bringToFront = self.bringToFront;
    animationCopy.delegate = self.delegate;
    animationCopy.userInfo = [NSDictionary dictionaryWithDictionary:self.userInfo];
    
    return animationCopy;
}

#pragma mark Animation callbacks

- (void)animationStepWillStart:(NSString *)animationID context:(void *)context
{
    // This callback is still called when an animation is cancelled before it actually started (i.e. if a delay has been
    // set). Do not notify the delegate in such cases
    if (! self.cancelling) {
        HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
        
        // Notify just before the execution of the first step (if a delay has been set, this event is not fired until the
        // delay period is over, as for UIView animation blocks)
        if ([self.animationSteps indexOfObject:animationStep] == 0) {
            if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
                [self.delegate animationWillStart:self animated:YES];
            }        
        }
    }    
}

- (void)animationStepDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
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
        HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
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
