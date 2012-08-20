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

- (void)animationDidStart:(CAAnimation *)animation;
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag;

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

- (CGFloat)alphaVariationForView:(UIView *)view
{
    CGFloat alphaVariation = 0.f;
    for (HLSAnimationStep *animationStep in self.animationSteps) {
        alphaVariation += [animationStep alphaVariationForView:view];
    }
    return alphaVariation;
}

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
    BOOL actuallyAnimated = animated && ! doubleeq(animationStep.duration, 0.f);
    if (actuallyAnimated) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:animationStep.duration];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        // TODO: Delay and timing function (curve)
        
        // The delay is just used for the first step. Set it to 0 for the remaining ones
        m_delay = 0.;
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
      
    // Animate all views involved in the animation step
    for (UIView *view in [animationStep views]) {
        // The views are brought to the front in the order they were registered with the animation step
        if (self.bringToFront) {
            [view.superview bringSubviewToFront:view];
        }
        
        HLSViewAnimationStep *viewAnimationStep = [animationStep viewAnimationStepForView:view];
        NSAssert(viewAnimationStep != nil, @"Missing animation step; data consistency failure");
        
        // Remark: For each property we animate, we still must set the final value manually (CoreAnimations
        //         animate properties but do not set them)
        NSMutableArray *animations = [NSMutableArray array];
        
        // Opacity always between 0.f and 1.f
        CGFloat opacity = view.layer.opacity + viewAnimationStep.alphaVariation;
        if (floatlt(opacity, -1.f)) {
            HLSLoggerWarn(@"Animation steps adding to an opacity value larger than -1 for view %@. Fixed to -1, but your animation is incorrect", view);
            opacity = -1.f;
        }
        else if (floatgt(opacity, 1.f)) {
            HLSLoggerWarn(@"Animation steps adding to an opacity value larger than 1 for view %@. Fixed to 1, but your animation is incorrect", view);
            opacity = 1.f;
        }
        
        if (actuallyAnimated) {
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [opacityAnimation setFromValue:[NSNumber numberWithFloat:view.layer.opacity]];
            [opacityAnimation setToValue:[NSNumber numberWithFloat:opacity]];
            [animations addObject:opacityAnimation];
        }
        view.layer.opacity = opacity;
        
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
            
            // TODO: Use layer properties
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(-view.center.x, -view.center.y);
            CGAffineTransform affineConvTransform = CGAffineTransformConcat(CGAffineTransformConcat(translationTransform, affineTransform),
                                                                            CGAffineTransformInvert(translationTransform));
            CGRect endFrame = CGRectApplyAffineTransform(view.layer.frame, affineConvTransform);
            
            // The CALayer frame cannot be animated, we must animate bounds and position instead. Calculate them
            CGRect endBounds = CGRectMake(0.f, 0.f, CGRectGetWidth(endFrame), CGRectGetHeight(endFrame));
            CGPoint positionOffset = CGPointMake(CGRectGetMidX(endFrame) - CGRectGetMidX(view.layer.frame),
                                                 CGRectGetMidY(endFrame) - CGRectGetMidY(view.layer.frame));
            CGPoint endPosition = CGPointMake(view.layer.position.x + positionOffset.x,
                                              view.layer.position.y + positionOffset.y);
            
            if (actuallyAnimated) {
                CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                [boundsAnimation setFromValue:[NSValue valueWithCGRect:view.layer.bounds]];
                [boundsAnimation setToValue:[NSValue valueWithCGRect:endBounds]];
                [animations addObject:boundsAnimation];
                
                CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                [positionAnimation setFromValue:[NSValue valueWithCGPoint:view.layer.position]];
                [positionAnimation setToValue:[NSValue valueWithCGPoint:endPosition]];
                [animations addObject:positionAnimation];
            }
            view.layer.bounds = endBounds;
            view.layer.position = endPosition;
            
            // Ensure better subview resizing in some cases (e.g. UISearchBar)
            [view.layer layoutSublayers];
        }
        // Alter transform
        else {
            CATransform3D translationTransform = CATransform3DMakeTranslation(-view.layer.transform.m41, -view.layer.transform.m42, 0.f);
            CATransform3D convTransform = CATransform3DConcat(CATransform3DConcat(translationTransform, viewAnimationStep.transform),
                                                              CATransform3DInvert(translationTransform));
            CATransform3D transform = CATransform3DConcat(view.layer.transform, convTransform);
            
            if (actuallyAnimated) {
                CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
                [transformAnimation setFromValue:[NSValue valueWithCATransform3D:view.layer.transform]];
                [transformAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
                [animations addObject:transformAnimation];
            }
            view.layer.transform = transform;
        }
        
        // Create the animation group and attach it to the layer
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = [NSArray arrayWithArray:animations];
        [view.layer addAnimation:animationGroup forKey:nil];
    }
    
    // Animate the dummy view. It is also used to set a delegate (one for all animations in the transaction)
    // which will receive the start / end animation events
    if (actuallyAnimated) {
        CABasicAnimation *dummyViewOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        dummyViewOpacityAnimation.fromValue = [NSNumber numberWithFloat:self.dummyView.alpha];
        dummyViewOpacityAnimation.toValue = [NSNumber numberWithFloat:1.f - self.dummyView.alpha];
        dummyViewOpacityAnimation.delegate = self;
        [dummyViewOpacityAnimation setValue:animationStep forKey:@"animationStep"];
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
    for (UIView *view in [self.currentAnimationStep views]) {
        [view.layer removeAllAnimations];
    }
    
    // Play all remaining steps without animation
    [self playNextStepAnimated:NO];
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
            HLSAnimationStep *animationStepCopy = [[animationStep copyWithZone:zone] autorelease];
            [animationStepCopies addObject:animationStepCopy];
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

- (void)animationDidStart:(CAAnimation *)animation
{
    // This callback is still called when an animation is cancelled before it actually started (i.e. if a delay has been
    // set). Do not notify the delegate in such cases
    if (! self.cancelling) {
        HLSAnimationStep *animationStep = [animation valueForKey:@"animationStep"];
        
        // Notify just before the execution of the first step (if a delay has been set, this event is not fired until the
        // delay period is over, as for UIView animation blocks)
        if ([self.animationSteps indexOfObject:animationStep] == 0) {
            if ([self.delegate respondsToSelector:@selector(animationWillStart:animated:)]) {
                [self.delegate animationWillStart:self animated:YES];
            }
        }
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
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
        HLSAnimationStep *animationStep = [animation valueForKey:@"animationStep"];
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
