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

@interface HLSPlaceholderViewController ()

- (void)releaseViews;

@property (nonatomic, retain) UIViewController *oldInsetViewController;

- (NSArray *)twoViewAnimationStepDefinitionsForTransitionStyle:(HLSTransitionStyle)transitionStyle
                                        oldInsetViewController:(UIViewController *)oldInsetViewController
                                        newInsetViewController:(UIViewController *)newInsetViewController;
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
    self.delegate = nil;
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
    return [self setInsetViewController:insetViewController withTwoViewAnimationStepDefinitions:nil];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    NSArray *animationStepDefinitions = [self twoViewAnimationStepDefinitionsForTransitionStyle:transitionStyle
                                                                         oldInsetViewController:self.insetViewController 
                                                                         newInsetViewController:insetViewController];
    [self setInsetViewController:insetViewController withTwoViewAnimationStepDefinitions:animationStepDefinitions];
    
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
    
    // The returned animation steps contain the default durations set for this transition
    NSArray *animationStepDefinitions = [self twoViewAnimationStepDefinitionsForTransitionStyle:transitionStyle
                                                                         oldInsetViewController:self.insetViewController 
                                                                         newInsetViewController:insetViewController];
    
    // Calculate the total animation duration
    NSTimeInterval totalDuration = 0.;
    for (HLSTwoViewAnimationStepDefinition *animationStepDefinition in animationStepDefinitions) {
        totalDuration += animationStepDefinition.duration;
    }
    
    // Find out which factor must be applied to each animation step to preserve the animation appearance for the specified duration
    double factor = duration / totalDuration;
    
    // Distribute the total duration evenly among animation steps
    for (HLSTwoViewAnimationStepDefinition *animationStepDefinition in animationStepDefinitions) {
        animationStepDefinition.duration *= factor;
    }
    
    [self setInsetViewController:insetViewController withTwoViewAnimationStepDefinitions:animationStepDefinitions];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions;
{
    // If not changed, nothing to do
    if (m_insetViewController == insetViewController) {
        return;
    }
    
    // Remove any existing inset first
    if (m_insetViewAddedAsSubview) {
        // If the container is visible, deal with animation and lifecycle events for the old inset view
        if (m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {                        
            // Animated
            if ([twoViewAnimationStepDefinitions count] != 0) {
                // Forward disappearance events
                [m_insetViewController viewWillDisappear:YES];
                m_insetViewAddedAsSubview = NO;
                
                // Keep a ref to the removed view controller (and save settings) so that it can stay alive until it is removed
                self.oldInsetViewController = m_insetViewController;
                m_oldOriginalInsetViewTransform = m_originalInsetViewTransform;
                m_oldOriginalInsetViewAlpha = m_originalInsetViewAlpha;                
            }
            // Not animated
            else {
                // Forward disappearance events
                [m_insetViewController viewWillDisappear:NO];
                m_insetViewAddedAsSubview = NO;
                
                // Remove the view
                [m_insetViewController.view removeFromSuperview];
                
                // Forward disappearance events
                [m_insetViewController viewDidDisappear:NO];
                
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
                // Cannot apply a transform here; we must adjust the frame for autoresizing behavior to occur
                self.insetViewController.view.frame = self.placeholderView.bounds;
            }
            
            // Animated
            if ([twoViewAnimationStepDefinitions count] != 0) {
                // Notify the delegate
                if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
                    [self.delegate placeholderViewController:self
                                 willShowInsetViewController:m_insetViewController 
                                                    animated:YES];
                }
                
                // Forward appearance events
                [m_insetViewController viewWillAppear:YES];
                m_insetViewAddedAsSubview = YES;
                
                // Add the inset
                [self.placeholderView addSubview:insetView];
            }
            // Not animated
            else {                
                // Notify the delegate
                if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
                    [self.delegate placeholderViewController:self
                                 willShowInsetViewController:m_insetViewController 
                                                    animated:NO];
                } 
                
                // Forward appearance events
                [m_insetViewController viewWillAppear:NO];
                m_insetViewAddedAsSubview = YES;                
                
                // Add the inset
                [self.placeholderView addSubview:insetView];
                
                // Notify the delegate
                if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
                    [self.delegate placeholderViewController:self
                                  didShowInsetViewController:m_insetViewController 
                                                    animated:NO];
                }
                
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
    
    // Create the animation if any
    if ([twoViewAnimationStepDefinitions count] != 0) {
        UIView *oldInsetView = self.oldInsetViewController.view;
        UIView *newInsetView = m_insetViewController.view;
        
        NSMutableArray *animationSteps = [NSMutableArray array];
        for (HLSTwoViewAnimationStepDefinition *animationStepDefinition in twoViewAnimationStepDefinitions) {
            HLSAnimationStep *animationStep = [animationStepDefinition animationStepWithFirstView:oldInsetView
                                                                                       secondView:newInsetView];
            [animationSteps addObject:animationStep];
        }
        
        HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:animationSteps];
        animation.lockingUI = YES;
        animation.bringToFront = YES;
        animation.delegate = self;
        [animation play];
    }
}

@synthesize oldInsetViewController = m_oldInsetViewController;

@synthesize placeholderView = m_placeholderView;

@synthesize adjustingInset = m_adjustingInset;

@synthesize delegate = m_delegate;

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
            // Cannot apply a transform here; we must adjust the frame for autoresizing behavior to occur
            self.insetViewController.view.frame = self.placeholderView.bounds;
        }
        
        // Notify the delegate
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
            [self.delegate placeholderViewController:self
                         willShowInsetViewController:self.insetViewController 
                                            animated:animated];
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
        // Notify the delegate
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
            [self.delegate placeholderViewController:self
                          didShowInsetViewController:self.insetViewController 
                                            animated:animated];
        }        
        
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



#pragma mark Built-in transitions (return an array of HLSTwoViewAnimationStepDefinition objects)

- (NSArray *)twoViewAnimationStepDefinitionsForTransitionStyle:(HLSTransitionStyle)transitionStyle
                                        oldInsetViewController:(UIViewController *)oldInsetViewController
                                        newInsetViewController:(UIViewController *)newInsetViewController
{
    switch (transitionStyle) {
        case HLSTransitionStyleNone: {
            return nil;
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStyleCoverFromRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }   
            
        case HLSTransitionStyleCoverFromBottomRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStyleCrossDissolve: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-newInsetViewController.view.alpha];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-oldInsetViewController.view.alpha];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:newInsetViewController.view.alpha];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                        deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStylePushFromTop: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-self.placeholderView.frame.size.height];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                        deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:self.placeholderView.frame.size.height];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }    
            
        case HLSTransitionStylePushFromLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                        deltaY:0.f];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStylePushFromRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                        deltaY:0.f];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-self.placeholderView.frame.size.width
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        default: {
            logger_error(@"Unknown transition style");
            return nil;
            break;
        }
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

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationFinished:(HLSAnimation *)animation
{
    // The old inset view controller has disappeared
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
    
    // Notify the delegate
    if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
        [self.delegate placeholderViewController:self
                      didShowInsetViewController:self.insetViewController 
                                        animated:YES];
    } 
    
    // Forward appearance event of the new inset
    [self.insetViewController viewDidAppear:YES];
}

@end
