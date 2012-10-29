//
//  PlaceholderDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PlaceholderDemoViewController.h"

#import "ContainmentTestViewController.h"
#import "FixedSizeViewController.h"
#import "HeavyViewController.h"
#import "LandscapeOnlyViewController.h"
#import "LifeCycleTestViewController.h"
#import "MemoryWarningTestCoverViewController.h"
#import "PortraitOnlyViewController.h"
#import "StretchableViewController.h"

@interface PlaceholderDemoViewController ()

@property (nonatomic, retain) HeavyViewController *leftHeavyViewController;
@property (nonatomic, retain) HeavyViewController *rightHeavyViewController;

- (void)displayInsetViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;

@end

@implementation PlaceholderDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Preload view controllers before display. Yep, this is possible (not all placeholders have to be preloaded)!
        LifeCycleTestViewController *lifeCycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [self setInsetViewController:lifeCycleTestViewController atIndex:0];
        
        // We can even assign a transition animation. Since the view controller has been preloaded, it won't be played,
        // but it will later be used if we set the inset to nil
        ContainmentTestViewController *containmentTestViewController = [[[ContainmentTestViewController alloc] init] autorelease];
        [self setInsetViewController:containmentTestViewController atIndex:1 withTransitionClass:[HLSTransitionCoverFromBottom class]];
        
        self.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.leftHeavyViewController = nil;
    self.rightHeavyViewController = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    // Free heavy views in cache
    self.leftHeavyViewController.view = nil;
    self.rightHeavyViewController.view = nil;
    
    self.heavyButton = nil;
    self.transitionPickerView = nil;
    self.inTabBarControllerSwitch = nil;
    self.inNavigationControllerSwitch = nil;
    self.leftPlaceholderSwitch = nil;
    self.rightPlaceholderSwitch = nil;
    self.involvingChildrenForAutorotationSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize heavyButton = m_heavyButton;

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize inTabBarControllerSwitch = m_inTabBarControllerSwitch;

@synthesize inNavigationControllerSwitch = m_inNavigationControllerSwitch;

@synthesize leftPlaceholderSwitch = m_leftPlaceholderSwitch;

@synthesize rightPlaceholderSwitch = m_rightPlaceholderSwitch;

@synthesize leftHeavyViewController = m_leftHeavyViewController;

@synthesize rightHeavyViewController = m_rightHeavyViewController;

@synthesize involvingChildrenForAutorotationSwitch = m_involvingChildrenForAutorotationSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inTabBarControllerSwitch.on = NO;
    self.inNavigationControllerSwitch.on = NO;
    self.leftPlaceholderSwitch.on = YES;
    self.rightPlaceholderSwitch.on = YES;
    self.involvingChildrenForAutorotationSwitch.on = (self.autorotationMode == HLSAutorotationModeContainerAndVisibleChildren || self.autorotationMode == HLSAutorotationModeContainerAndAllChildren);
    
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    // We must prevent insertion of the same view controller twice (this yields an error)
    if ((self.leftHeavyViewController && self.leftPlaceholderSwitch.on && [self insetViewControllerAtIndex:0] == self.leftHeavyViewController)
        || (self.rightHeavyViewController && self.rightPlaceholderSwitch.on && [self insetViewControllerAtIndex:1] == self.rightHeavyViewController)) {
        self.heavyButton.hidden = YES;
    }
    else {
        self.heavyButton.hidden = NO;
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HLSPlaceholderViewController";
}

#pragma mark Displaying an inset view controller according to the user settings

- (void)displayInsetViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{    
    // We can even embed navigation and tab bar controllers within a placeolder view controller!
    UIViewController *insetViewController = viewController;
    if (insetViewController) {
        if (self.inNavigationControllerSwitch.on) {
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:insetViewController] autorelease];
            navigationController.autorotationMode = HLSAutorotationModeContainerAndVisibleChildren;
            insetViewController = navigationController;
        }
        if (self.inTabBarControllerSwitch.on) {
            UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
            tabBarController.viewControllers = [NSArray arrayWithObject:insetViewController];
            insetViewController = tabBarController;
        }    
    }
        
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    NSString *transitionName = [[HLSTransition availableTransitionNames] objectAtIndex:pickedIndex];
    
    @try {
        [self setInsetViewController:insetViewController atIndex:index withTransitionClass:NSClassFromString(transitionName)];
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                             message:NSLocalizedString(@"The view controller is not compatible with the container (most probably its orientation)",
                                                                                       @"The view controller is not compatible with the container (most probably its orientation)")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
}

#pragma mark HLSPlaceholderViewControllerDelegate protocol implementation

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willShowInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will show inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didShowInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did show inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
    
    if ((self.leftPlaceholderSwitch.on && index == 0 && viewController == self.leftHeavyViewController)
        || (self.rightPlaceholderSwitch.on && index == 1 && viewController == self.rightHeavyViewController)) {
        self.heavyButton.hidden = YES;
    }
    else {
        self.heavyButton.hidden = NO;
    }
}

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willHideInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will hide inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didHideInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did hide inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
    
    self.heavyButton.hidden = NO;
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[HLSTransition availableTransitionNames] count];
}

#pragma mark UIPickerViewDelegate protocol implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[HLSTransition availableTransitionNames] objectAtIndex:row];
}

#pragma mark Event callbacks

- (IBAction)displayLifeCycleTest:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        LifeCycleTestViewController *lifecycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [self displayInsetViewController:lifecycleTestViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        LifeCycleTestViewController *lifecycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [self displayInsetViewController:lifecycleTestViewController atIndex:1];
    }
}

- (IBAction)displayContainmentTest:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        ContainmentTestViewController *containmentTestViewController = [[[ContainmentTestViewController alloc] init] autorelease];
        [self displayInsetViewController:containmentTestViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        ContainmentTestViewController *containmentTestViewController = [[[ContainmentTestViewController alloc] init] autorelease];
        [self displayInsetViewController:containmentTestViewController atIndex:1];
    }    
}

- (IBAction)displayStretchable:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        StretchableViewController *stretchableViewController = [[[StretchableViewController alloc] init] autorelease];
        [self displayInsetViewController:stretchableViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        StretchableViewController *stretchableViewController = [[[StretchableViewController alloc] init] autorelease];
        [self displayInsetViewController:stretchableViewController atIndex:1];
    }
}

- (IBAction)displayFixedSize:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        FixedSizeViewController *fixedSizeViewController = [[[FixedSizeViewController alloc] init] autorelease];
        [self displayInsetViewController:fixedSizeViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        FixedSizeViewController *fixedSizeViewController = [[[FixedSizeViewController alloc] init] autorelease];
        [self displayInsetViewController:fixedSizeViewController atIndex:1];
    }
}

- (IBAction)displayHeavy:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    // Store a strong ref to an already built HeavyViewController; this way, this view controller is kept alive and does
    // not need to be recreated from scratch each time it is displayed as inset (lazy creation suffices). This proves 
    // that caching view controller's views is made possible by HLSPlaceholderViewController if needed
    if (self.leftPlaceholderSwitch.on) {
        if (! self.leftHeavyViewController) {
            self.leftHeavyViewController = [[[HeavyViewController alloc] init] autorelease];
        }
        [self displayInsetViewController:self.leftHeavyViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        if (! self.rightHeavyViewController) {
            self.rightHeavyViewController = [[[HeavyViewController alloc] init] autorelease];
        }
        [self displayInsetViewController:self.rightHeavyViewController atIndex:1];
    }
}

- (IBAction)displayPortraitOnly:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        PortraitOnlyViewController *portraitOnlyViewController = [[[PortraitOnlyViewController alloc] init] autorelease];
        [self displayInsetViewController:portraitOnlyViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        PortraitOnlyViewController *portraitOnlyViewController = [[[PortraitOnlyViewController alloc] init] autorelease];
        [self displayInsetViewController:portraitOnlyViewController atIndex:1];
    }
}

- (IBAction)displayLandscapeOnly:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        LandscapeOnlyViewController *landscapeOnlyViewController = [[[LandscapeOnlyViewController alloc] init] autorelease];
        [self displayInsetViewController:landscapeOnlyViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        LandscapeOnlyViewController *landscapeOnlyViewController = [[[LandscapeOnlyViewController alloc] init] autorelease];
        [self displayInsetViewController:landscapeOnlyViewController atIndex:1];
    }
}

- (IBAction)remove:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        [self setInsetViewController:nil atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        [self setInsetViewController:nil atIndex:1];
    }
}

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    [self presentModalViewController:memoryWarningTestCoverViewController animated:YES];
}

- (IBAction)togglePlaceholder:(id)sender
{
    // We must prevent insertion of the same view controller twice (this yields an error)
    if ((self.leftHeavyViewController && self.leftPlaceholderSwitch.on && [self insetViewControllerAtIndex:0] == self.leftHeavyViewController)
        || (self.rightHeavyViewController && self.rightPlaceholderSwitch.on && [self insetViewControllerAtIndex:1] == self.rightHeavyViewController)) {
        self.heavyButton.hidden = YES;
    }
    else {
        self.heavyButton.hidden = NO;
    }
}

- (IBAction)toggleInvolvingChildrenForAutorotation:(id)sender
{
    if (self.involvingChildrenForAutorotationSwitch.on) {
        self.autorotationMode = HLSAutorotationModeContainerAndAllChildren;
    }
    else {
        self.autorotationMode = HLSAutorotationModeContainer;
    }
}

- (IBAction)navigateForwardNonAnimated:(id)sender
{
    PlaceholderDemoViewController *placeholderDemoViewController = [[[PlaceholderDemoViewController alloc] init] autorelease];
    [self.navigationController pushViewController:placeholderDemoViewController animated:NO];
}

- (IBAction)navigateBackNonAnimated:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
