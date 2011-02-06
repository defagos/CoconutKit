//
//  HLSPlaceholderViewController.m
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSOrientationCloner.h"
#import "HLSRuntimeChecks.h"
#import "HLSTransform.h"
#import "HLSViewAnimation.h"

@interface HLSPlaceholderViewController ()

- (void)releaseViews;

@property (nonatomic, retain) UIViewController *oldInsetViewController;

- (NSArray *)fadeOutAnimationStepsForTransitionStyle:(HLSTransitionStyle)transitionStyle viewController:(UIViewController *)viewController;
- (NSArray *)fadeInAnimationStepsForTransitionStyle:(HLSTransitionStyle)transitionStyle viewController:(UIViewController *)viewController;

@end

@implementation HLSPlaceholderViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        m_lifeCyclePhase = LifeCyclePhaseInitialized;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        m_lifeCyclePhase = LifeCyclePhaseInitialized;
    }
    return self;
}

- (void)dealloc
{
    [self releaseViews];
    self.insetViewController = nil;
    self.oldInsetViewController = nil;
    self.placeholderView = nil;
    [super dealloc];
}

- (void)releaseViews
{
    self.placeholderView = nil;
}

#pragma mark Accessors and mutators

@synthesize insetViewController = m_insetViewController;

- (void)setInsetViewController:(UIViewController *)insetViewController
{
    return [self setInsetViewController:insetViewController withFadeOutAnimationSteps:nil fadeInAnimationSteps:nil];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
     withFadeOutAnimationSteps:(NSArray *)fadeOutAnimationSteps
          fadeInAnimationSteps:(NSArray *)fadeInAnimationSteps
{
    // If not changed, nothing to do
    if (m_insetViewController == insetViewController) {
        return;
    }
    
    // If animated, reset status tracker
    if ([fadeOutAnimationSteps count] != 0) {
        m_fadeOutAnimationComplete = NO;
    }
    // Not animated; consider as done
    else {
        m_fadeOutAnimationComplete = YES;
    }
    
    if ([fadeInAnimationSteps count] != 0) {
        m_fadeInAnimationComplete = NO;
    }
    else {
        m_fadeInAnimationComplete = YES;
    }
    
    // Remove any existing inset first
    if (m_insetViewAddedAsSubview) {
        // If visible, forward disappearance events
        if (m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {
            // Animated
            if ([fadeOutAnimationSteps count] != 0) {
                // Forward disappearance events
                [m_insetViewController viewWillDisappear:YES];
                m_insetViewAddedAsSubview = NO;
                
                // Keep a ref to the removed view controller so that it can stay alive until the animation ends; also save the
                // view controller's view original properties we might have altered to restore them at the end of the animation
                self.oldInsetViewController = m_insetViewController;
                m_oldOriginalInsetViewTransform = m_originalInsetViewTransform;
                m_oldOriginalInsetViewAlpha = m_originalInsetViewAlpha;
                
                // Animate
                HLSViewAnimation *fadeOutViewAnimation = [HLSViewAnimation viewAnimationWithAnimationSteps:fadeOutAnimationSteps];
                fadeOutViewAnimation.tag = @"fadeOut";
                fadeOutViewAnimation.lockingUI = YES;
                fadeOutViewAnimation.bringToFront = NO;
                fadeOutViewAnimation.delegate = self;
                [fadeOutViewAnimation animateView:m_insetViewController.view];
            }
            // Not animated
            else {
                // Forward disappearance events
                [m_insetViewController viewWillDisappear:NO];
                m_insetViewAddedAsSubview = NO;
                
                // Remove the view
                [m_insetViewController.view removeFromSuperview];
                
                // Forward disappearance events
                if (m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {
                    [m_insetViewController viewDidDisappear:NO];
                }
                
                // Restore the original view properties we might have altered during the time the view controller was
                // set as inset
                m_insetViewController.view.transform = m_originalInsetViewTransform;
                m_insetViewController.view.alpha = m_originalInsetViewAlpha;
            }
        }
    }
    
    // Change the view controller
    [m_insetViewController release];
    m_insetViewController = [insetViewController retain];
    
    // Add the new inset if the placeholder is available
    if (m_insetViewController && m_lifeCyclePhase >= LifeCyclePhaseViewDidLoad && m_lifeCyclePhase < LifeCyclePhaseViewDidUnload) {
        // Instantiate the view lazily (if it has not been already been instantiated, which should be the case in most
        // situations). This will trigger the associated viewDidLoad
        UIView *insetView = m_insetViewController.view;
        
        // Save original parameters which can get altered by view controller animations; this way we can restore the original
        // state of the view controller's view when it gets removed. This allows callers to cache the view controller (and its
        // view) for reusing them at a later time. We must restore these parameters since the caller must expect to be able
        // to reuse a view in the same state existing before the view controller was assigned as inset
        m_originalInsetViewTransform = insetView.transform;
        m_originalInsetViewAlpha = insetView.alpha;
        
        // If already visible, forward appearance events (this event here correctly occurs after viewDidLoad)
        if (m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {
            // Adjust the frame to get proper autoresizing behavior (if autoresizesSubviews has been enabled for the placeholder
            // view). This is carefully made before notifying the inset view controller that it will appear, so that clients can
            // safely rely on the fact that dimensions of view controller's views have been set before viewWillAppear gets called
            if (self.adjustingInset) {
                // We do not adjust the frame directly here but use a transform. According to UIView's documentation, we must avoid
                // mixing frame and transforms
                insetView.transform = [HLSTransform transformFromRect:insetView.frame 
                                                               toRect:self.placeholderView.bounds];
            }
            
            // Animated
            if ([fadeInAnimationSteps count] != 0) {
                // To avoid seing the view before the animation begins (creating an ugly flick), we make it invisible and move it 
                // out of the placeholder view bounds first. We must then ensure we restore the alpha by modifying the first animation 
                // step provided by the caller
                CGFloat hideInsetViewAlphaVariation = -insetView.alpha;
                insetView.alpha += hideInsetViewAlphaVariation;
                CGAffineTransform hideInsetViewTransform = CGAffineTransformMakeTranslation(self.placeholderView.frame.size.width, 
                                                                                            self.placeholderView.frame.size.height);
                insetView.transform = CGAffineTransformConcat(hideInsetViewTransform, insetView.transform);
                
                // Forward appearance events
                [m_insetViewController viewWillAppear:YES];
                m_insetViewAddedAsSubview = YES;
                
                // Add the inset
                [self.placeholderView addSubview:insetView];
      
                // Alter the first animation to negate the initial changes applied above
                HLSAnimationStep *firstFadeInAnimationStep = [fadeInAnimationSteps objectAtIndex:0];
                firstFadeInAnimationStep.alphaVariation -= hideInsetViewAlphaVariation;
                firstFadeInAnimationStep.transform = CGAffineTransformConcat(firstFadeInAnimationStep.transform, 
                                                                             CGAffineTransformInvert(hideInsetViewTransform));
                
                // Animate
                HLSViewAnimation *fadeInViewAnimation = [HLSViewAnimation viewAnimationWithAnimationSteps:fadeInAnimationSteps];
                fadeInViewAnimation.tag = @"fadeIn";
                fadeInViewAnimation.lockingUI = YES;
                fadeInViewAnimation.bringToFront = YES;
                fadeInViewAnimation.delegate = self;
                [fadeInViewAnimation animateView:insetView];
            }
            // Not animated
            else {
                // Forward appearance events
                [m_insetViewController viewWillAppear:NO];
                m_insetViewAddedAsSubview = YES;
                
                // Add the inset
                [self.placeholderView addSubview:insetView];
                
                // Forward appearance events
                [m_insetViewController viewDidAppear:NO];                
            }
        }
        // Not visible or disappearing
        else {
            // Add the inset
            [self.placeholderView addSubview:insetView];
            m_insetViewAddedAsSubview = YES;            
        }
    }
}

- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
{    
    // The returned animation steps contain the default durations for each step
    NSArray *fadeOutAnimationSteps = [self fadeOutAnimationStepsForTransitionStyle:transitionStyle viewController:self.insetViewController];
    NSArray *fadeInAnimationSteps = [self fadeInAnimationStepsForTransitionStyle:transitionStyle viewController:insetViewController];
    
    [self setInsetViewController:insetViewController 
       withFadeOutAnimationSteps:fadeOutAnimationSteps 
            fadeInAnimationSteps:fadeInAnimationSteps];     
}

- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration
{
    // Sanitize input
    if (doublelt(duration, 0.)) {
        logger_warn(@"Duration must be non-negative. Fixed to 0");
        duration = 0.;
    }
    
    // The returned animation steps contain the default durations for each step
    NSArray *fadeOutAnimationSteps = [self fadeOutAnimationStepsForTransitionStyle:transitionStyle viewController:self.insetViewController];
    NSArray *fadeInAnimationSteps = [self fadeInAnimationStepsForTransitionStyle:transitionStyle viewController:insetViewController];
    
    // Distribute durations evenly among fade out animation steps
    NSTimeInterval fadeOutDuration = 0.;
    for (HLSAnimationStep *fadeOutAnimationStep in fadeOutAnimationSteps) {
        fadeOutDuration += fadeOutAnimationStep.duration;
    }
    double fadeOutFactor = duration / fadeOutDuration;
    for (HLSAnimationStep *fadeOutAnimationStep in fadeOutAnimationSteps) {
        fadeOutAnimationStep.duration *= fadeOutFactor;
    }
    
    // Distribute durations evenly among fade in animation steps
    NSTimeInterval fadeInDuration = 0.;
    for (HLSAnimationStep *fadeInAnimationStep in fadeInAnimationSteps) {
        fadeInDuration += fadeInAnimationStep.duration;
    }
    double fadeInFactor = duration / fadeInDuration;
    for (HLSAnimationStep *fadeInAnimationStep in fadeInAnimationSteps) {
        fadeInAnimationStep.duration *= fadeInFactor;
    }    
    
    [self setInsetViewController:insetViewController 
       withFadeOutAnimationSteps:fadeOutAnimationSteps 
            fadeInAnimationSteps:fadeInAnimationSteps];    
}

@synthesize oldInsetViewController = m_oldInsetViewController;

@synthesize placeholderView = m_placeholderView;

@synthesize adjustingInset = m_adjustingInset;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // All animations must take place within the placeholder area, even those which move views outside it. We
    // do not want views in the placeholder view to overlap with views outside it, so we clip views to match
    // the placeholder area
    self.placeholderView.clipsToBounds = YES;
    
    // At the end: update life cycle status
    m_lifeCyclePhase = LifeCyclePhaseViewDidLoad;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If an inset has been defined but not displayed yet, add it (remark: This is not done in viewDidLoad since only
    // now are the placeholder view dimensions known)
    if (self.insetViewController && ! m_insetViewAddedAsSubview) {
        UIView *insetView = self.insetViewController.view;
        
        // Save original parameters which can get altered by view controller animations; this way we can restore the original
        // state of the view controller's view when it gets removed. This allows callers to cache the view controller (and its
        // view) for reusing them at a later time. We must restore these parameters since the caller must expect to be able
        // to reuse a view in the same state existing before the view controller was assigned as inset
        m_originalInsetViewTransform = insetView.transform;
        m_originalInsetViewAlpha = insetView.alpha;
        
        [self.placeholderView addSubview:insetView];
        m_insetViewAddedAsSubview = YES;
    }
    
    if (m_insetViewAddedAsSubview) {
        // Adjust the frame to get proper autoresizing behavior (if autoresizesSubviews has been enabled for the placeholder
        // view). This is carefully made before notifying the inset view controller that it will appear, so that clients can
        // safely rely on the fact that dimensions of view controller's views have been set before viewWillAppear gets called
        if (self.adjustingInset) {
            // We do not adjust the frame directly here but use a transform. According to UIView's documentation, we must avoid
            // mixing frame and transforms
            self.insetViewController.view.transform = [HLSTransform transformFromRect:self.insetViewController.view.frame 
                                                                               toRect:self.placeholderView.bounds];
        }
        
        [self.insetViewController viewWillAppear:animated];
    }    
    
    // At the end: update life cycle status    
    m_lifeCyclePhase = LifeCyclePhaseViewWillAppear;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (m_insetViewAddedAsSubview) {
        [self.insetViewController viewDidAppear:animated];
    }
    
    // At the end: update life cycle status
    m_lifeCyclePhase = LifeCyclePhaseViewDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (m_insetViewAddedAsSubview) {
        [self.insetViewController viewWillDisappear:animated];
    }
    
    // At the end: update life cycle status
    m_lifeCyclePhase = LifeCyclePhaseViewWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (m_insetViewAddedAsSubview) {
        [self.insetViewController viewDidDisappear:animated];
    }
    
    // At the end: update life cycle status
    m_lifeCyclePhase = LifeCyclePhaseViewDidDisappear;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self releaseViews];
    
    if (m_insetViewAddedAsSubview) {
        self.insetViewController.view = nil;
        m_insetViewAddedAsSubview = NO;
        
        [self.insetViewController viewDidUnload];
    }
    
    // At the end: update life cycle status
    m_lifeCyclePhase = LifeCyclePhaseViewDidUnload;
}

#pragma mark Orientation management (these methods are only called if the view controller is visible)

// TODO: HLSOrientationCloner: More difficult that what we have here; we have to keep two references during the rotation:
//       the references to the view controller and its rotated clones. Both must be sent the rotation events
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#if 0

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{ 
    
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

#endif

#pragma mark Built-in transitions (return an array of HLSAnimationStep objects)

- (NSArray *)fadeOutAnimationStepsForTransitionStyle:(HLSTransitionStyle)transitionStyle viewController:(UIViewController *)viewController
{
    // Remark: Animations take place only when the placeholder view controller is visible, these methods are therefore called in such cases only.
    //         This guarantees that the placeholder view frame we use below is well defined 
    switch (transitionStyle) {
        case HLSTransitionStyleCoverFromBottom:
        case HLSTransitionStyleCoverFromTop:
        case HLSTransitionStyleCoverFromLeft:
        case HLSTransitionStyleCoverFromRight: 
        case HLSTransitionStyleCoverFromUpperLeft: 
        case HLSTransitionStyleCoverFromUpperRight:
        case HLSTransitionStyleCoverFromBottomLeft:
        case HLSTransitionStyleCoverFromBottomRight: 
        case HLSTransitionStyleEmergeFromCenter: {
            // Keep the old view alive for the duration of the associated fade in animation
            HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
            animationStep.duration = 0.4;
            return [NSArray arrayWithObject:animationStep];
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
            // This triggers view creation a little bit earlier than in cases where alpha is not involved, but we have no other choice to find 
            // the needed alpha variation
            CGFloat viewAlpha = viewController.view.alpha;            
            animationStep.alphaVariation = -viewAlpha;
            animationStep.duration = 0.4;
            return [NSArray arrayWithObject:animationStep];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            HLSAnimationStep *animationStep = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:0.f 
                                                                                                deltaY:-self.placeholderView.frame.size.height];
            animationStep.duration = 0.4;
            return [NSArray arrayWithObject:animationStep];
            break;
        }
            
        case HLSTransitionStylePushFromTop: {
            HLSAnimationStep *animationStep = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:0.f 
                                                                                                deltaY:self.placeholderView.frame.size.height];
            animationStep.duration = 0.4;
            return [NSArray arrayWithObject:animationStep];            
            break;
        }
            
        case HLSTransitionStylePushFromLeft: {
            HLSAnimationStep *animationStep = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width 
                                                                                                deltaY:0.f];
            animationStep.duration = 0.4;
            return [NSArray arrayWithObject:animationStep];
            break;
        }
            
        case HLSTransitionStylePushFromRight: {
            HLSAnimationStep *animationStep = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width 
                                                                                                deltaY:0.f];
            animationStep.duration = 0.4;
            return [NSArray arrayWithObject:animationStep];            
            break;
        }
            
        default:
            return nil;
    }
}

- (NSArray *)fadeInAnimationStepsForTransitionStyle:(HLSTransitionStyle)transitionStyle viewController:(UIViewController *)viewController
{
    // Remark: Animations take place only when the placeholder view controller is visible, these methods are therefore called in such cases only.
    //         This guarantees that the placeholder view frame we use below is well defined     
    switch (transitionStyle) {
        case HLSTransitionStyleCoverFromBottom: 
        case HLSTransitionStylePushFromBottom: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:0.f 
                                                                                                 deltaY:self.placeholderView.frame.size.height];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:0.f 
                                                                                                 deltaY:-self.placeholderView.frame.size.height];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: 
        case HLSTransitionStylePushFromTop: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:0.f 
                                                                                                 deltaY:-self.placeholderView.frame.size.height];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:0.f 
                                                                                                 deltaY:self.placeholderView.frame.size.height];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft:
        case HLSTransitionStylePushFromLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width 
                                                                                                 deltaY:0.f];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                 deltaY:0.f];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromRight: 
        case HLSTransitionStylePushFromRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width 
                                                                                                 deltaY:0.f];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                 deltaY:0.f];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromUpperLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width 
                                                                                                 deltaY:-self.placeholderView.frame.size.height];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                 deltaY:self.placeholderView.frame.size.height];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromUpperRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width 
                                                                                                 deltaY:-self.placeholderView.frame.size.height];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                 deltaY:self.placeholderView.frame.size.height];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width 
                                                                                                 deltaY:self.placeholderView.frame.size.height];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                 deltaY:-self.placeholderView.frame.size.height];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width 
                                                                                                 deltaY:self.placeholderView.frame.size.height];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                 deltaY:-self.placeholderView.frame.size.height];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }            
            
        case HLSTransitionStyleCrossDissolve: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            // This triggers view creation a little bit earlier than in cases where alpha is not involved, but we have no other choice to find 
            // the needed alpha variation
            CGFloat viewAlpha = viewController.view.alpha;
            animationStep1.alphaVariation = -viewAlpha;
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            animationStep2.alphaVariation = viewAlpha;
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        case HLSTransitionStyleEmergeFromCenter: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            // This triggers view creation a little bit earlier than in cases where alpha is not involved, but we have no other choice to find 
            // the needed alpha variation
            CGRect viewFrame = viewController.view.frame;
            CGRect centerPointFrame = CGRectMake((viewFrame.size.width - 0.1f) / 2,
                                                 (viewFrame.size.height - 0.1f) / 2,
                                                 0.1f,      // Cannot use 0 here (otherwise nan in the transform)
                                                 0.1f);
            animationStep1.transform = [HLSTransform transformFromRect:viewFrame toRect:centerPointFrame];
            animationStep1.duration = 0.;
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            animationStep2.transform = [HLSTransform transformFromRect:centerPointFrame toRect:viewFrame];
            animationStep2.duration = 0.4;
            return [NSArray arrayWithObjects:animationStep1, animationStep2, nil];
            break;
        }
            
        default:
            return nil;
            break;
    }
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    if ([self.insetViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableInsetViewController = self.insetViewController;
        [reloadableInsetViewController reloadData];
    }
}

#pragma mark HLSViewAnimationDelegate protocol implementation

- (void)viewAnimationFinished:(HLSViewAnimation *)viewAnimation
{
    if ([viewAnimation.tag isEqual:@"fadeOut"]) {
        m_fadeOutAnimationComplete = YES;
    }
    else if ([viewAnimation.tag isEqual:@"fadeIn"]) {
        m_fadeInAnimationComplete = YES;
        
        // Forward appearance events
        [m_insetViewController viewDidAppear:YES];
    }
    
    // Both animation complete; we can now remove the old view controller's view. This makes animations where the new
    // view controller covers the previous one possible
    if (m_fadeInAnimationComplete && m_fadeOutAnimationComplete) {
        // Remove the view
        [self.oldInsetViewController.view removeFromSuperview];
        
        [self.oldInsetViewController viewDidDisappear:YES];
        
        // Restore the original view properties we might have altered during the time the view controller was
        // set as inset
        self.oldInsetViewController.view.transform = m_oldOriginalInsetViewTransform;
        self.oldInsetViewController.view.alpha = m_oldOriginalInsetViewAlpha;
        
        // Done with the old inset view controller.
        self.oldInsetViewController = nil;
        m_oldOriginalInsetViewTransform = CGAffineTransformIdentity;
        m_oldOriginalInsetViewAlpha = 0.f;
    }
}

@end
