//
//  HLSViewAnimation.m
//  nut
//
//  Created by Samuel DEFAGO on 8/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimation.h"

#import "HLSConverters.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSRuntimeChecks.h"
#import "HLSUserInterfaceLock.h"

@interface HLSViewAnimation ()

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSArray *animationSteps;
@property (nonatomic, retain) NSEnumerator *stepsEnumerator;

- (void)animateStep:(HLSAnimationStep *)animationStep;

- (void)animateNextStep;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation HLSViewAnimation

#pragma mark Class methods

+ (HLSViewAnimation *)viewAnimationWithView:(UIView *)view animationSteps:(NSArray *)animationSteps
{
    return [[[[self class] alloc] initWithView:view animationSteps:animationSteps] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithView:(UIView *)view animationSteps:(NSArray *)animationSteps;
{
    if (self = [super init]) {
        self.view = view;
        
        // Add an identity step first; this is mandatory in order to be able to generate the inverse animation
        HLSAnimationStep *identityAnimationStep = [HLSAnimationStep animationStepIdentityForView:self.view];
        self.animationSteps = [NSArray arrayWithObject:identityAnimationStep];
        
        // Add the steps supplied as parameter, replacing non-set values of alpha with their real value. This
        // is needed to be able to generate the correct reverse animation
        CGFloat previousAlpha = identityAnimationStep.alpha;
        for (HLSAnimationStep *animationStep in animationSteps) {
            HLSAnimationStep *animationStepCopy = [animationStep copy];
            if (floateq(animationStepCopy.alpha, ANIMATION_STEP_ALPHA_NOT_SET)) {
                animationStepCopy.alpha = previousAlpha;
            }
            previousAlpha = animationStepCopy.alpha;
            self.animationSteps = [self.animationSteps arrayByAddingObject:animationStepCopy];
        }
        self.lockingUI = NO;
        self.bringToFront = NO;
    }
    return self;
}

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    self.view = nil;
    self.animationSteps = nil;
    self.stepsEnumerator = nil;
    self.tag = nil;
    self.delegate = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize view = m_view;

@synthesize animationSteps = m_animationSteps;

@synthesize stepsEnumerator = m_stepsEnumerator;

@synthesize tag = m_tag;

@synthesize lockingUI = m_lockingUI;

@synthesize bringToFront = m_bringToFront;

@synthesize delegate = m_delegate;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; view: <%@: %p>; animationSteps: %@; tag: %@; lockingUI: %@, bringToFront: %@, delegate: %p>", 
            [self class],
            self,
            [self.view class],
            self.view,
            self.animationSteps,
            self.tag,
            [HLSConverters stringFromBool:self.lockingUI],
            [HLSConverters stringFromBool:self.bringToFront],
            self.delegate];
}

#pragma mark Animation

- (void)play
{
    // Lock the UI during the animation
    if (self.lockingUI) {
        [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    }
    
    if (self.bringToFront) {
        [self.view.superview bringSubviewToFront:self.view];
    }
    
    // Begin with the first step
    [self animateNextStep];
}

/**
 * About animating views with subviews: We cannot get a satisfying animation behavior
 * if we try to animate a view with subviews by altering the containing view frame property 
 * within an animation block (only the containing view gets properly animated).
 * To have a view and all its subviews properly animated, we must use the UIView transform
 * property and affine transformations. This is nice, since it is also the cleanest way
 * to write transformations.
 */
- (void)animateStep:(HLSAnimationStep *)animationStep
{
    [UIView beginAnimations:nil context:animationStep];
    
    [UIView setAnimationDuration:animationStep.duration];
    [UIView setAnimationDelay:animationStep.delay];
    [UIView setAnimationCurve:animationStep.curve];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    // No unset alpha must remain after initialization
    NSAssert(! floateq(animationStep.alpha, ANIMATION_STEP_ALPHA_NOT_SET), @"An alpha has not been set correctly for an animation step");
    self.view.alpha = animationStep.alpha;
    
    // The fact that transform is a property is essential. If you "po" a UIView in gdb, you will see something like:
    //   <UIView: 0x4d57c40; frame = (141 508; 136 102); transform = [1, 0, 0, 1, 30, -60]; autoresize = RM+BM; layer = <CALayer: 0x4d57cc0>>
    // i.e. the view is attached a transform, not applied a transform which would get lost after it has been applied. If
    // we already have a transformed which is applied, we therefore need to compose it with the transform we are applying during
    // the step
    self.view.transform = CGAffineTransformConcat(animationStep.transform, self.view.transform);
    
    [UIView commitAnimations];
}

- (void)animateNextStep
{
    // First call?
    if (! self.stepsEnumerator) {
        self.stepsEnumerator = [self.animationSteps objectEnumerator];
    }
    
    // Proceeed with the next step (if any)
    HLSAnimationStep *nextAnimationStep = [self.stepsEnumerator nextObject];
    if (nextAnimationStep) {
        [self animateStep:nextAnimationStep];
    }
    else {
        self.stepsEnumerator = nil;
        
        // Unlock the UI
        if (self.lockingUI) {
            [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
        }
        
        if ([self.delegate respondsToSelector:@selector(viewAnimationFinished:)]) {
            [self.delegate viewAnimationFinished:self];
        }
    }    
}

#pragma mark Creating the reverse animation

- (HLSViewAnimation *)reverseViewAnimation
{
    NSMutableArray *reverseAnimationSteps = [NSMutableArray array];
    
    // Create an initial identity step
    HLSAnimationStep *identityAnimationStep = [HLSAnimationStep animationStepIdentityForView:self.view];
    [reverseAnimationSteps addObject:identityAnimationStep];
    
    // Two pointers to be kept in parallel: Current step and previous one (reverse steps are composed of data stemming from
    // both)
    NSEnumerator *animationStepReverseEnumerator = [self.animationSteps reverseObjectEnumerator];
    HLSAnimationStep *previousAnimationStep = [animationStepReverseEnumerator nextObject];
    HLSAnimationStep *animationStep = [animationStepReverseEnumerator nextObject];
    while (animationStep) {
        // Most attributes are the same as the previous animation step (but reversed), therefore deep copy first
        HLSAnimationStep *reverseAnimationStep = [previousAnimationStep copy];
        reverseAnimationStep.transform = CGAffineTransformInvert(reverseAnimationStep.transform);
        
        // Reverse the curve
        switch (reverseAnimationStep.curve) {
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
        
        // Must reach alpha of the CURRENT step, though
        reverseAnimationStep.alpha = animationStep.alpha;
        
        // Add step
        [reverseAnimationSteps addObject:reverseAnimationStep];
        
        // Update cursors
        previousAnimationStep = animationStep;
        animationStep = [animationStepReverseEnumerator nextObject];
    }
    
    // No properties set, just view and steps
    return [HLSViewAnimation viewAnimationWithView:self.view animationSteps:[NSArray arrayWithArray:reverseAnimationSteps]];
}

#pragma mark Animation callbacks

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    HLSAnimationStep *animationStep = (HLSAnimationStep *)context;

    if ([self.delegate respondsToSelector:@selector(viewAnimationStepFinished:)]) {
        [self.delegate viewAnimationStepFinished:animationStep];
    }
    
    [self animateNextStep];
}

@end
