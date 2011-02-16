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
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
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
    
    // Check that the new inset can be displayed for the current orientation
    if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
        if (! [insetViewController shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
            logger_error(@"The inset view controller cannot be set because it does not support the current interface orientation");
            return;
        }
    }
    
    // Remove any existing inset first
    if (m_insetViewAddedAsSubview) {
        // If the container is visible, deal with animation and lifecycle events for the old inset view
        if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {                        
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
    if (m_insetViewController && [self lifeCyclePhase] >= HLSViewControllerLifeCyclePhaseViewDidLoad && [self lifeCyclePhase] < HLSViewControllerLifeCyclePhaseViewDidUnload) {
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
        if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (m_insetViewAddedAsSubview) {
        [self.insetViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (m_insetViewAddedAsSubview) {
        [self.insetViewController viewDidDisappear:animated];
    }
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
}

#pragma mark Orientation management (these methods are only called if the view controller is visible)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{    
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // If no inset has been defined, let the placeholder rotate
    if (! self.insetViewController) {
        return YES;
    }
    
    return [self.insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
        || [self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)];    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If no inset has been defined, we are done
    if (! self.insetViewController) {
        return;
    }
    
    // If the view controller can rotate by cloning, clone it. Since we use 1-step rotation (smoother, default since iOS3),
    // we cannot swap it in the middle of the animation. Instead, we use a cross-dissolve transition so that the change
    // happens smoothly during the rotation
    if ([self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
        UIViewController<HLSOrientationCloner> *clonableInsetViewController = self.insetViewController;
        UIViewController *clonedInsetViewController = [clonableInsetViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
        [self setInsetViewController:clonedInsetViewController 
                 withTransitionStyle:HLSTransitionStyleCrossDissolve
                            duration:duration];
    }
    
    [self.oldInsetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.insetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If no inset defined, we are done
    if (! self.insetViewController) {
        return;
    }
    
    [self.oldInsetViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.insetViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // If no inset defined, we are done
    if (! self.insetViewController) {
        return;
    }
    
    // Remark: We could have feared that oldInsetViewController is nil when the rotation animation ends (since the
    //         cross-fade animation is supposed to end at the same time and could have released it). Well, it seems
    //         to work correctly, oldViewController is not nil and receives the event correctly. I do not want to
    //         add cumbersome code for this now, let's wait and see if problems arise
    [self.oldInsetViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.insetViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

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
            
        case HLSTransitionStyleEmergeFromCenter:  {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            HLSViewAnimationStep *secondViewAnimationStep1 = [HLSViewAnimationStep viewAnimationStep];
            secondViewAnimationStep1.transform = CGAffineTransformMakeScale(0.01f, 0.01f);      // cannot use 0.f, otherwise infinite matrix elements
            animationStepDefinition1.secondViewAnimationStep = secondViewAnimationStep1;
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            HLSViewAnimationStep *secondViewAnimationStep2 = [HLSViewAnimationStep viewAnimationStep];
            secondViewAnimationStep2.transform = CGAffineTransformInvert(secondViewAnimationStep1.transform);
            animationStepDefinition2.secondViewAnimationStep = secondViewAnimationStep2;
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

- (void)animationDidStop:(HLSAnimation *)animation
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
