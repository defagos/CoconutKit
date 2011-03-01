//
//  HLSAnimation.m
//  nut
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

- (void)animateStep:(HLSAnimationStep *)animationStep;

- (void)animateNextStep;

- (NSArray *)reverseAnimationSteps;

- (void)animationWillStart:(NSString *)animationID context:(void *)context;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation HLSAnimation

#pragma mark Class methods

+ (HLSAnimation *)animationWithAnimationSteps:(NSArray *)animationSteps
{
    return [[[[self class] alloc] initWithAnimationSteps:animationSteps] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithAnimationSteps:(NSArray *)animationSteps;
{
    HLSAssertObjectsInEnumerationAreKindOfClass(animationSteps, HLSAnimationStep);
    if ((self = [super init])) {
        self.animationSteps = animationSteps;
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
    self.delegate = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize animationSteps = m_animationSteps;

@synthesize animationStepsEnumerator = m_animationStepsEnumerator;

@synthesize tag = m_tag;

@synthesize lockingUI = m_lockingUI;

@synthesize bringToFront = m_bringToFront;

@synthesize delegate = m_delegate;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; animationSteps: %@; tag: %@; lockingUI: %@, bringToFront: %@, delegate: %p>", 
            [self class],
            self,
            self.animationSteps,
            self.tag,
            [HLSConverters stringFromBool:self.lockingUI],
            [HLSConverters stringFromBool:self.bringToFront],
            self.delegate];
}

#pragma mark Animation

- (void)play
{
    // Cannot be played if already running (equivalently, we can test we are iterating over steps)
    if (self.animationStepsEnumerator) {
        logger_debug(@"The animation is already running");
        return;
    }
    
    // Lock the UI during the animation
    if (self.lockingUI) {
        [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    }
    
    // Begin with the first step
    [self animateNextStep];
}

- (void)animateStep:(HLSAnimationStep *)animationStep
{
    // If duration is 0, do not create an animation block; creating such useless animation blocks might cause flickering
    // in animations
    if (! doubleeq(animationStep.duration, 0.f)) {
        [UIView beginAnimations:nil context:animationStep];
        
        [UIView setAnimationDuration:animationStep.duration];
        [UIView setAnimationCurve:animationStep.curve];
        
        [UIView setAnimationWillStartSelector:@selector(animationWillStart:context:)];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
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
            logger_warn(@"Animation steps adding to value larger than -1 for view %@. Fixed to -1, but your animation is incorrect", view);
            view.alpha = -1.f;
        }
        else if (floatgt(alpha, 1.f)) {
            logger_warn(@"Animation steps adding to value larger than 1 for view %@. Fixed to 1, but your animation is incorrect", view);
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
    if (! doubleeq(animationStep.duration, 0.f)) {
        [UIView commitAnimations];
        
        // The code will resume in the animationDidStop:finished:context: method
    }
    // Instantaneous
    else {
        // Notify the end of the animation
        if ([self.delegate respondsToSelector:@selector(animationStepFinished:)]) {
            [self.delegate animationStepFinished:animationStep];
        }
        
        [self animateNextStep];
    }
}

- (void)animateNextStep
{
    // First call?
    if (! self.animationStepsEnumerator) {
        self.animationStepsEnumerator = [self.animationSteps objectEnumerator];
        m_firstStep = YES;
    }
    
    // Proceeed with the next step (if any)
    HLSAnimationStep *nextAnimationStep = [self.animationStepsEnumerator nextObject];
    if (nextAnimationStep) {
        [self animateStep:nextAnimationStep];
    }
    // Done with the animation
    else {
        self.animationStepsEnumerator = nil;
        
        // Unlock the UI
        if (self.lockingUI) {
            [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
        }
        
        if ([self.delegate respondsToSelector:@selector(animationDidStop:)]) {
            [self.delegate animationDidStop:self];
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

- (void)animationWillStart:(NSString *)animationID context:(void *)context
{
    if (m_firstStep) {
        if ([self.delegate respondsToSelector:@selector(animationWillStart:)]) {
            [self.delegate animationWillStart:self];
        }
        
        m_firstStep = NO;
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
    
    if ([self.delegate respondsToSelector:@selector(animationStepFinished:)]) {
        [self.delegate animationStepFinished:animationStep];
    }
    
    [self animateNextStep];
}

@end
