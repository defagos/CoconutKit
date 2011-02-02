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

@interface HLSPlaceholderViewController ()

- (void)releaseViews;

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
    // If not changed, nothing to do
    if (m_insetViewController == insetViewController) {
        return;
    }
    
    // Remove any existing inset first
    if (m_insetViewAddedAsSubview) {
        // If visible, forward disappearance events
        if (m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {
            [m_insetViewController viewWillDisappear:NO];
        }
        
        // Remove the view
        [m_insetViewController.view removeFromSuperview];
        m_insetViewAddedAsSubview = NO;
        
        // If visible, forward disappearance events
        if (m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {
            [m_insetViewController viewDidDisappear:NO];
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
        
        // If soon or already visible, forward appearance events (this event here correctly occurs after viewDidLoad)
        if (m_lifeCyclePhase == LifeCyclePhaseViewWillAppear || m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {
            // Adjust the frame to get proper autoresizing behavior (if autoresizesSubviews has been enabled for the placeholder
            // view). This is carefully made before notifying the inset view controller that it will appear, so that clients can
            // safely rely on the fact that dimensions of view controller's views have been set before viewWillAppear gets called
            if (self.adjustingInset) {
                insetView.frame = self.placeholderView.bounds;
            }
            
            [m_insetViewController viewWillAppear:NO];
        }
        
        // Add the inset
        [self.placeholderView addSubview:insetView];
        m_insetViewAddedAsSubview = YES;
        
        // If visible, forward appearance events
        if (m_lifeCyclePhase == LifeCyclePhaseViewDidAppear) {
            [m_insetViewController viewDidAppear:NO];
        }
    }
}

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
        [self.placeholderView addSubview:self.insetViewController.view];
        m_insetViewAddedAsSubview = YES;
    }
    
    if (m_insetViewAddedAsSubview) {
        // Adjust the frame to get proper autoresizing behavior (if autoresizesSubviews has been enabled for the placeholder
        // view). This is carefully made before notifying the inset view controller that it will appear, so that clients can
        // safely rely on the fact that dimensions of view controller's views have been set before viewWillAppear gets called
        if (self.adjustingInset) {
            self.insetViewController.view.frame = self.placeholderView.bounds;
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

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    if ([self.insetViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableInsetViewController = self.insetViewController;
        [reloadableInsetViewController reloadData];
    }
}

@end
