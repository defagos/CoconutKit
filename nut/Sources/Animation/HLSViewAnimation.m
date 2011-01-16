//
//  HLSViewAnimation.m
//  nut
//
//  Created by Samuel DEFAGO on 8/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimation.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSRuntimeChecks.h"
#import "HLSUserInterfaceLock.h"

@interface HLSViewAnimation ()

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSArray *animationSteps;
@property (nonatomic, retain) NSEnumerator *stepsEnumerator;
@property (nonatomic, retain) NSMutableArray *previousStepAlphas;
@property (nonatomic, retain) NSArray *parentZOrderedViews;

- (void)animateStep:(HLSAnimationStep *)animationStep;
- (void)reverseAnimateStep:(HLSAnimationStep *)animationStep;

- (void)animateNextStep;
- (void)reverseAnimateNextStep;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)reverseAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation HLSViewAnimation

#pragma mark Object creation and destruction

- (id)initWithView:(UIView *)view animationSteps:(NSArray *)animationSteps;
{
    if (self = [super init]) {
        self.view = view;
        self.animationSteps = animationSteps;
        self.previousStepAlphas = [NSMutableArray array];
        self.lockingUI = NO;
        self.alwaysOnTop = NO;
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
    self.previousStepAlphas = nil;
    self.stepsEnumerator = nil;
    self.tag = nil;
    self.parentZOrderedViews = nil;
    self.delegate = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize view = m_view;

@synthesize animationSteps = m_animationSteps;

@synthesize stepsEnumerator = m_stepsEnumerator;

@synthesize previousStepAlphas = m_previousStepAlphas;

@synthesize tag = m_tag;

@synthesize lockingUI = m_lockingUI;

@synthesize alwaysOnTop = m_alwaysOnTop;

@synthesize parentZOrderedViews = m_parentZOrderedViews;

@synthesize delegate = m_delegate;

#pragma mark Animation

- (void)animate
{
    // Lock the UI during the animation
    if (self.lockingUI) {
        [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    }
    
    // If desired, we put the view in front to ensure the animation looks always good (otherwise the view might be hidden by
    // other views). This requires us to save the Z-ordering for restoring it when the reverse animation is played.
    // This can be achieved simply by saving the view array since it is sorted according to the Z-order. This feature
    // is undocumented, so this trick might break in the future, but it is currently the cheapest solution. The lowest
    // index corresponds to the view with the lowest Z-order
    if (self.alwaysOnTop) {
        self.parentZOrderedViews = self.view.superview.subviews;
        
        // Bring the view to animate to the front
        [self.view.superview bringSubviewToFront:self.view];
    }
    
    // Begin with the first step
    [self animateNextStep];
}

- (void)animateReverse
{
    // Lock the UI during the animation
    if (self.lockingUI) {
        [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    }
    
    // Begin with the last step
    [self reverseAnimateNextStep];
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
    // Save the alpha at the beginning (so that we can later play the reverse animation)
    NSNumber *previousAlpha = [NSNumber numberWithFloat:self.view.alpha];
    [self.previousStepAlphas addObject:previousAlpha];
    
    [UIView beginAnimations:nil context:animationStep];
    
    [UIView setAnimationDuration:animationStep.duration];
    [UIView setAnimationDelay:animationStep.delay];
    [UIView setAnimationCurve:animationStep.curve];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    // Animate the view; alpha is altered only if set
    if (! floateq(animationStep.alpha, ANIMATION_STEP_ALPHA_NOT_SET)) {
        self.view.alpha = animationStep.alpha;
    }
    
    // The fact that transform is a property is essential. If you "po" a UIView in gdb, you will see something like:
    //   <UIView: 0x4d57c40; frame = (141 508; 136 102); transform = [1, 0, 0, 1, 30, -60]; autoresize = RM+BM; layer = <CALayer: 0x4d57cc0>>
    // i.e. the view is attached a transform, not applied a transform which would get lost after it has been applied. If
    // we already have a transformed which is applied, we therefore need to compose it with the transform we are applying during
    // the step
    self.view.transform = CGAffineTransformConcat(animationStep.transform, self.view.transform);
    
    [UIView commitAnimations];
}

- (void)reverseAnimateStep:(HLSAnimationStep *)animationStep
{
    [UIView beginAnimations:nil context:animationStep];
    
    [UIView setAnimationDuration:animationStep.duration];
    [UIView setAnimationDelay:animationStep.delay];
    
    // Reverse the curve
    UIViewAnimationCurve curve;
    switch (animationStep.curve) {
        case UIViewAnimationCurveEaseIn:
            curve = UIViewAnimationCurveEaseOut;
            break;
            
        case UIViewAnimationCurveEaseOut:
            curve = UIViewAnimationCurveEaseIn;
            break;
            
        default:
            curve = animationStep.curve;
            break;
    }
    [UIView setAnimationCurve:curve];
    
    [UIView setAnimationDidStopSelector:@selector(reverseAnimationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    // Animate the view; retrieve the alpha to reach, and remove it from the history
    float previousAlpha = [[self.previousStepAlphas lastObject] floatValue];
    self.view.alpha = previousAlpha;
    [self.previousStepAlphas removeLastObject];
    
    // See remark in animateStep:; we remove the transform
    self.view.transform = CGAffineTransformConcat(CGAffineTransformInvert(animationStep.transform), self.view.transform);
    
    [UIView commitAnimations];    
}

- (void)animateNextStep
{
    // First call?
    if (! self.stepsEnumerator) {
        self.stepsEnumerator = [self.animationSteps objectEnumerator];
        [self.previousStepAlphas removeAllObjects];
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

- (void)reverseAnimateNextStep
{
    // First call?
    if (! self.stepsEnumerator) {
        self.stepsEnumerator = [self.animationSteps reverseObjectEnumerator];
    }    
    
    // Proceeed with the next step (if any)
    HLSAnimationStep *nextAnimationStep = [self.stepsEnumerator nextObject];
    if (nextAnimationStep) {
        [self reverseAnimateStep:nextAnimationStep];
    }
    else {
        self.stepsEnumerator = nil;
        NSAssert([self.previousStepAlphas count] == 0, @"Different number of steps in reverse animation");
        
        // Unlock the UI
        if (self.lockingUI) {
            [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
        }
        
        // Restore initial Z-ordering
        if (self.alwaysOnTop) {
            for (UIView *view in self.parentZOrderedViews) {
                [self.view.superview bringSubviewToFront:view];
            }
            self.parentZOrderedViews = nil;
        }
        
        if ([self.delegate respondsToSelector:@selector(viewAnimationFinishedReverse:)]) {
            [self.delegate viewAnimationFinishedReverse:self];
        }
    }
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

- (void)reverseAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    HLSAnimationStep *animationStep = (HLSAnimationStep *)context;
    if ([self.delegate respondsToSelector:@selector(viewAnimationStepFinishedReverse:)]) {
        [self.delegate viewAnimationStepFinishedReverse:animationStep];
    }    
    
    [self reverseAnimateNextStep];
}

@end
