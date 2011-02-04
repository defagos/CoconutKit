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

- (NSArray *)reverseAnimationSteps:(NSArray *)animationSteps;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation HLSViewAnimation

#pragma mark Class methods

+ (HLSViewAnimation *)viewAnimationWithAnimationSteps:(NSArray *)animationSteps
{
    return [[[[self class] alloc] initWithAnimationSteps:animationSteps] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithAnimationSteps:(NSArray *)animationSteps;
{
    if (self = [super init]) {
        self.animationSteps = animationSteps;
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

- (void)animateView:(UIView *)view
{
    // Cannot be played if already running
    if (self.view) {
        logger_debug(@"The animation is already running");
        return;
    }
    
    self.view = view;
    
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
 * within an animation block (only the containing view gets properly animated, not the
 * subviews).
 * To have a view and all its subviews properly animated, we must use the UIView transform
 * property and apply affine transformations. This is nice, since it is also the cleanest way
 * to write transformations.
 */
- (void)animateStep:(HLSAnimationStep *)animationStep
{
    [UIView beginAnimations:nil context:animationStep];
    
    [UIView setAnimationDuration:animationStep.duration];
    [UIView setAnimationCurve:animationStep.curve];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    // Alpha always between 0.f and 1.f
    CGFloat alpha = self.view.alpha + animationStep.alphaVariation;
    if (floatlt(alpha, -1.f)) {
        logger_warn(@"Animation steps adding to value larger than -1. Fixed to -1, but your animation is incorrect");
        self.view.alpha = -1.f;
    }
    else if (floatgt(alpha, 1.f)) {
        logger_warn(@"Animation steps adding to value larger than 1. Fixed to 1, but your animation is incorrect");
        self.view.alpha = 1.f;
    }
    else {
        self.view.alpha = alpha;
    }
    
    // The fact that transform is a property is essential. If you "po" a UIView in gdb, you will see something like:
    //   <UIView: 0x4d57c40; frame = (141 508; 136 102); transform = [1, 0, 0, 1, 30, -60]; autoresize = RM+BM; layer = <CALayer: 0x4d57cc0>>
    // i.e. the view is attached a transform, not applied a transform which would get lost after it has been applied. If
    // we already have a transform which is applied, we therefore need to compose it with the transform we are applying during
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
    // Done with the animation
    else {
        self.view = nil;
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
    NSArray *animationSteps = [self reverseAnimationSteps:self.animationSteps];
    HLSViewAnimation *reverseViewAnimation = [HLSViewAnimation viewAnimationWithAnimationSteps:animationSteps];
    reverseViewAnimation.tag = [NSString stringWithFormat:@"reverse_%@", self.tag];
    reverseViewAnimation.lockingUI = self.lockingUI;
    reverseViewAnimation.bringToFront = self.bringToFront;
    reverseViewAnimation.delegate = self.delegate;
    
    return reverseViewAnimation;
}

- (NSArray *)reverseAnimationSteps:(NSArray *)animationSteps
{
    if (! animationSteps) {
        return nil;
    }
    
    NSMutableArray *reverseAnimationSteps = [NSMutableArray array];
    for (HLSAnimationStep *animationStep in [animationSteps reverseObjectEnumerator]) {
        HLSAnimationStep *reverseAnimationStep = [HLSAnimationStep animationStep];
        reverseAnimationStep.transform = CGAffineTransformInvert(animationStep.transform);
        reverseAnimationStep.alphaVariation = -animationStep.alphaVariation;
        reverseAnimationStep.duration = animationStep.duration;
        
        // Reverse the curve
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

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
    
    if ([self.delegate respondsToSelector:@selector(viewAnimationStepFinished:)]) {
        [self.delegate viewAnimationStepFinished:animationStep];
    }
    
    [self animateNextStep];
}

@end
