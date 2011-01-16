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

@interface HLSPlaceholderViewController ()

@property (nonatomic, retain) UIViewController *oldInsetViewController;
@property (nonatomic, retain) NSArray *fadeInAnimationSteps;

- (void)displayInsetViewController:(UIViewController *)insetViewController withFadeInAnimationSteps:(NSArray *)fadeInAnimationSteps;
- (void)removeInsetViewController:(UIViewController *)insetViewController withFadeOutAnimationSteps:(NSArray *)fadeOutAnimationSteps;

@end

@implementation HLSPlaceholderViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        m_firstDisplay = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        m_firstDisplay = YES;
    }
    return self;
}

- (void)dealloc
{
    self.insetViewController = nil;
    self.oldInsetViewController = nil;
    self.fadeInAnimationSteps = nil;
    self.placeholderView = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize insetViewController = m_insetViewController;

- (void)setInsetViewController:(UIViewController *)insetViewController
{
    // No animation
    [self setInsetViewController:insetViewController withFadeOutAnimationSteps:nil fadeInAnimationSteps:nil];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
     withFadeOutAnimationSteps:(NSArray *)fadeOutAnimationSteps
          fadeInAnimationSteps:(NSArray *)fadeInAnimationSteps
{
    // If the inset view controller is not being changed, nothing to do
    if (m_insetViewController == insetViewController) {
        return;
    }
    
    // Save animation values just in case we need to play them later
    self.fadeInAnimationSteps = fadeInAnimationSteps;
    
    // Remove the old inset if it was displayed
    // TODO: Better condition!
    if (m_insetViewController.view) {
        [self removeInsetViewController:m_insetViewController withFadeOutAnimationSteps:fadeOutAnimationSteps];
    }
    
    // Update the value
    [m_insetViewController release];
    m_insetViewController = [insetViewController retain];
    
    // Display the new inset if the placeholder is already visible
    if (self.placeholderView && m_insetViewController) {
        [self displayInsetViewController:m_insetViewController withFadeInAnimationSteps:fadeInAnimationSteps];
    }
}

@synthesize oldInsetViewController = m_oldInsetViewController;

@synthesize fadeInAnimationSteps = m_fadeInAnimationSteps;

@synthesize placeholderView = m_placeholderView;

@synthesize autoresizesInset = m_autoresizesInset;

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.autoresizesInset) {
        // Now that the dimensions are known (because the view is about to be displayed), adjust the inset
        // frame so that the behavior is correct regardless of the inset autoresizing mask
        self.insetViewController.view.frame = self.placeholderView.bounds;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (m_firstDisplay) {
        if (self.insetViewController) {
            [self displayInsetViewController:self.insetViewController withFadeInAnimationSteps:self.fadeInAnimationSteps];
        }
        m_firstDisplay = NO;
    }
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.placeholderView = nil;
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // If no inset has been defined, let the placeholder rotate
    if (! self.insetViewController) {
        return YES;
    }
    
    return [self.insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
    || [self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [self.insetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // If no inset defined, nothing to do
    if (! self.insetViewController) {
        return;
    }
    
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

#pragma mark Displaying and removing view controllers

- (void)displayInsetViewController:(UIViewController *)insetViewController withFadeInAnimationSteps:(NSArray *)fadeInAnimationSteps
{
    // Get the new inset; this lazily creates the associated view if it does not already exist
    UIView *insetView = insetViewController.view;
    
    if (self.autoresizesInset) {
        // Adjust its frame
        insetView.frame = self.placeholderView.bounds;
    }
        
    // Display with an animation
    if (fadeInAnimationSteps) {
        [insetViewController viewWillAppear:YES];
        [self.placeholderView addSubview:insetView];
        
        // Create the animation
        HLSViewAnimation *fadeInViewAnimation = [[[HLSViewAnimation alloc] initWithView:insetView 
                                                                         animationSteps:fadeInAnimationSteps]
                                                 autorelease];
        fadeInViewAnimation.tag = @"fadeIn";
        fadeInViewAnimation.lockingUI = YES;
        fadeInViewAnimation.alwaysOnTop = YES;
        fadeInViewAnimation.delegate = self;
        [fadeInViewAnimation animate];
    }
    // Display without animation
    else {
        [insetViewController viewWillAppear:NO];
        [self.placeholderView addSubview:insetView];
        [insetViewController viewDidAppear:NO];            
    }
}

- (void)removeInsetViewController:(UIViewController *)insetViewController withFadeOutAnimationSteps:(NSArray *)fadeOutAnimationSteps
{
    // Animated
    if (fadeOutAnimationSteps) {
        [insetViewController viewWillDisappear:YES];
        
        // Store a strong ref to the view controller to be dismissed sot that it stays alive during animation
        self.oldInsetViewController = insetViewController;
        
        // Create the animation
        HLSViewAnimation *fadeOutViewAnimation = [[[HLSViewAnimation alloc] initWithView:self.oldInsetViewController.view 
                                                                          animationSteps:fadeOutAnimationSteps]
                                                  autorelease];
        
        fadeOutViewAnimation.tag = @"fadeOut";
        fadeOutViewAnimation.lockingUI = YES;
        fadeOutViewAnimation.alwaysOnTop = NO;
        fadeOutViewAnimation.delegate = self;
        [fadeOutViewAnimation animate];
    }
    // Remove without animation
    else {
        [insetViewController viewWillDisappear:NO];
        [insetViewController.view removeFromSuperview];
        [insetViewController viewDidDisappear:NO];
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
    // Just to be sure that nothing bad happens if some fool tries to reuse the animation
    viewAnimation.delegate = nil;
    
    // Fade in done
    if ([viewAnimation.tag isEqual:@"fadeIn"]) {
        [self.oldInsetViewController.view removeFromSuperview];
        [self.oldInsetViewController viewDidDisappear:YES];
    }
    // Fade out done
    else {
        [self.insetViewController viewDidAppear:YES];
        
        self.oldInsetViewController = nil;
    }
}

@end
