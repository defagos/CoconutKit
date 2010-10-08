//
//  HLSPlaceholderViewController.m
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

#import "HLSLogger.h"
#import "HLSOrientationCloner.h"
#import "HLSRuntimeChecks.h"

@implementation HLSPlaceholderViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)dealloc
{
    self.insetViewController = nil;
    self.placeholderView = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize insetViewController = m_insetViewController;

- (void)setInsetViewController:(UIViewController *)insetViewController
{
    // If the inset view controller is not being changed, nothing to do
    if (m_insetViewController == insetViewController) {
        return;
    }
    
    // Remove the old inset if it was displayed
    if (m_insetViewController.view) {
        [m_insetViewController viewWillDisappear:NO];
        [m_insetViewController.view removeFromSuperview];
        [m_insetViewController viewDidDisappear:NO];        
    }
    
    // Update the value
    [m_insetViewController release];
    m_insetViewController = [insetViewController retain];
    
    // Display the new inset if the placeholder is already visible
    if (self.placeholderView) {
        // Get the new inset; this lazily creates the associated view
        UIView *insetView = m_insetViewController.view;
        
        // Adjust its frame
        insetView.frame = self.placeholderView.bounds;
        
        // Display the new inset
        [m_insetViewController viewWillAppear:NO];
        [self.placeholderView addSubview:insetView];
        [m_insetViewController viewDidAppear:NO];
    }
}

@synthesize placeholderView = m_placeholderView;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.placeholderView addSubview:self.insetViewController.view];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.placeholderView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.insetViewController viewWillAppear:animated];
    
    // Now that the dimensions are known (because the view is about to be displayed), adjust the inset
    // frame so that the behavior is correct regardless of the inset autoresizing mask
    self.insetViewController.view.frame = self.placeholderView.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.insetViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.insetViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.insetViewController viewDidDisappear:animated];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
        || [self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [self.insetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Forward to the view controllers first
    [self.insetViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If the view controller can autorotate, just keep it (it will deal with its own orientation). Note that controllers
    // which can autorotate by generating another view does implement shouldAutorotateToInterfaceOrientation:,
    // but return NO for this orientation
    if ([self.insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        // Nothing to do
    }
    // If the view controller can rotate by cloning, create and use the clone for the new orientation
    else if ([self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
        UIViewController<HLSOrientationCloner> *clonableInsetViewController = self.insetViewController;
        UIViewController *clonedInsetViewController = [clonableInsetViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
        
        self.insetViewController = clonedInsetViewController;
    }
    // Should never happen, shouldAutorotateToInterfaceOrientation: returned YES if we arrived in this method
    else {
        logger_error(@"The inset view controller cannot be rotated");
    }
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{ 
    [self.insetViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];    
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.insetViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];    
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.insetViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.insetViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self reloadData];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    if ([self.insetViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableInsetViewController = self.insetViewController;
        [reloadableInsetViewController reloadData];
    }
}

@end
