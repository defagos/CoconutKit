//
//  HLSViewAnimation.m
//  nut
//
//  Created by Samuel DEFAGO on 8/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimation.h"

#import "HLSRuntimeChecks.h"
#import "HLSUserInterfaceLock.h"

// Default values as given by Apple UIView documentation
#define ANIMATION_SETTINGS_DEFAULT_DURATION          0.2f
#define ANIMATION_SETTINGS_DEFAULT_DELAY             0.0f
#define ANIMATION_SETTINGS_DEFAULT_CURVE             UIViewAnimationCurveEaseInOut

@interface HLSViewAnimation ()

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSArray *animationFrames;
@property (nonatomic, retain) NSArray *parentZOrderedViews;

- (void)endAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation HLSViewAnimation

#pragma mark Object creation and destruction

- (id)initWithView:(UIView *)view animationFrames:(NSArray *)animationFrames;
{
    if (self = [super init]) {
        self.view = view;
        self.animationFrames = animationFrames;
        // Default settings
        self.duration = ANIMATION_SETTINGS_DEFAULT_DURATION;
        self.delay = ANIMATION_SETTINGS_DEFAULT_DELAY;
        self.curve = ANIMATION_SETTINGS_DEFAULT_CURVE;
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
    self.animationFrames = nil;
    self.id = nil;
    self.parentZOrderedViews = nil;
    self.delegate = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize view = m_view;

@synthesize animationFrames = m_animationFrames;

@synthesize id = m_id;

@synthesize duration = m_duration;

@synthesize delay = m_delay;

@synthesize curve = m_curve;

@synthesize parentZOrderedViews = m_parentZOrderedViews;

@synthesize delegate = m_delegate;

#pragma mark Animation

/**
 * About animating views with subviews: We cannot get a satisfying animation behavior
 * if we try to animate a view with subviews by altering the containing view frame property 
 * within an animation block (only the containing view gets properly animated).
 * To have a view and all its subviews properly animated, we must use the UIView transform
 * property and affine transformations. This is nice, since it is also the cleanest way
 * to write transformations.
 */
- (void)animate
{
    // Locke the UI during the animation
    [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    
    // We will put the view in front to ensure the animation looks always good (otherwise the view might be hidden by
    // other views). This requires us to save the Z-ordering for restoring it when the reverse animation is played.
    // This can be achieved simply by saving the view array since it is sorted according to the Z-order. This feature
    // is undocumented, so this trick might break in the future, but it is currently the cheapest solution. The lowest
    // index corresponds to the view with the lowest Z-order
    self.parentZOrderedViews = self.view.superview.subviews;
    
    // Bring the view to animate to the front
    [self.view.superview bringSubviewToFront:self.view];
    
    // Create the animation
    [UIView beginAnimations:@"normal" context:nil];
    
    [UIView setAnimationDuration:self.duration];
    [UIView setAnimationDelay:self.delay];
    [UIView setAnimationCurve:self.curve];
    
    [UIView setAnimationDidStopSelector:@selector(endAnimationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    // Animate through the frames
    for (HLSAnimationFrame *animationFrame in self.animationFrames) {
        self.view.alpha = animationFrame.alpha;
        self.view.transform = animationFrame.transform;
    }
    
    [UIView commitAnimations];
}

- (void)animateReverse
{
    // Lock the UI during the animation
    [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
    
    // Create the animation
    [UIView beginAnimations:@"reverse" context:nil];
    
    [UIView setAnimationDuration:self.duration];
    [UIView setAnimationDelay:self.delay];
    [UIView setAnimationCurve:self.curve];
    
    [UIView setAnimationDidStopSelector:@selector(endAnimationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    // Animate through the frames (reverse)
    for (HLSAnimationFrame *animationFrame in [self.animationFrames reverseObjectEnumerator]) {
        self.view.alpha = animationFrame.alpha;
        self.view.transform = animationFrame.transform;
    }
    
    [UIView commitAnimations];
}

#pragma mark Animation callbacks

- (void)endAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // Unlocks the UI
    [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
    
    if ([animationID isEqual:@"normal"]) {
        [self.delegate viewAnimationFinished:self];
    }
    else {
        [self.delegate viewAnimationFinishedReverse:self];
        
        // Restore the initial Z-ordering
        for (UIView *view in self.parentZOrderedViews) {
            [self.view.superview bringSubviewToFront:view];
        }
        self.parentZOrderedViews = nil;
    }
}

@end
