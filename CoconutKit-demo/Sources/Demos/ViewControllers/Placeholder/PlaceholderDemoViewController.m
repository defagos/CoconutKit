//
//  PlaceholderDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PlaceholderDemoViewController.h"

#import "ContainerCustomizationViewController.h"
#import "FixedSizeViewController.h"
#import "HeavyViewController.h"
#import "LandscapeOnlyViewController.h"
#import "LifeCycleTestViewController.h"
#import "MemoryWarningTestCoverViewController.h"
#import "OrientationClonerViewController.h"
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
        // Preload a view controller before display. Yep, this is possible (and not all placeholders have to be preloaded)!
        LifeCycleTestViewController *lifeCycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [self setInsetViewController:lifeCycleTestViewController atIndex:1];
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
    
    self.inTabBarControllerSwitch = nil;
    self.inNavigationControllerSwitch = nil;
    self.transitionPickerView = nil;
    self.forwardingPropertiesSwitch = nil;
    self.leftPlaceholderSwitch = nil;
    self.rightPlaceholderSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize inTabBarControllerSwitch = m_inTabBarControllerSwitch;

@synthesize inNavigationControllerSwitch = m_inNavigationControllerSwitch;

@synthesize forwardingPropertiesSwitch = m_forwardingPropertiesSwitch;

@synthesize leftPlaceholderSwitch = m_leftPlaceholderSwitch;

@synthesize rightPlaceholderSwitch = m_rightPlaceholderSwitch;

@synthesize leftHeavyViewController = m_leftHeavyViewController;

@synthesize rightHeavyViewController = m_rightHeavyViewController;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inTabBarControllerSwitch.on = NO;
    self.inNavigationControllerSwitch.on = NO;
    self.forwardingPropertiesSwitch.on = self.forwardingProperties;
    self.leftPlaceholderSwitch.on = YES;
    self.rightPlaceholderSwitch.on = YES;
    
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
}

#pragma mark Displaying an inset view controller according to the user settings

- (void)displayInsetViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{    
    // We can even embed navigation and tab bar controllers within a placeolder view controller!
    UIViewController *insetViewController = viewController;
    if (insetViewController) {
        if (self.inNavigationControllerSwitch.on) {
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:insetViewController] autorelease];
            insetViewController = navigationController;
        }
        if (self.inTabBarControllerSwitch.on) {
            UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
            tabBarController.viewControllers = [NSArray arrayWithObject:insetViewController];
            insetViewController = tabBarController;
        }    
    }
        
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    [self setInsetViewController:insetViewController atIndex:index withTransitionStyle:pickedIndex];
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

- (IBAction)displayOrientationCloner:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        OrientationClonerViewController *orientationClonerViewController = [[[OrientationClonerViewController alloc] 
                                                                             initWithPortraitOrientation:UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
                                                                             large:NO]
                                                                            autorelease];
        [self displayInsetViewController:orientationClonerViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        OrientationClonerViewController *orientationClonerViewController = [[[OrientationClonerViewController alloc] 
                                                                             initWithPortraitOrientation:UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
                                                                             large:NO]
                                                                            autorelease];
        [self displayInsetViewController:orientationClonerViewController atIndex:1];
    }
}

- (IBAction)displayContainerCustomization:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        ContainerCustomizationViewController *containerCustomizationViewController = [[[ContainerCustomizationViewController alloc] init] autorelease];
        [self displayInsetViewController:containerCustomizationViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        ContainerCustomizationViewController *containerCustomizationViewController = [[[ContainerCustomizationViewController alloc] init] autorelease];
        [self displayInsetViewController:containerCustomizationViewController atIndex:1];
    }
}

- (IBAction)toggleForwardingProperties:(id)sender
{
    self.forwardingProperties = self.forwardingPropertiesSwitch.on;
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

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return HLSTransitionStyleEnumSize;
}

#pragma mark UIPickerViewDelegate protocol implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case HLSTransitionStyleNone: {
            return @"HLSTransitionStyleNone";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            return @"HLSTransitionStyleCoverFromBottom";
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            return @"HLSTransitionStyleCoverFromTop";
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            return @"HLSTransitionStyleCoverFromLeft";
            break;
        }
            
        case HLSTransitionStyleCoverFromRight: {
            return @"HLSTransitionStyleCoverFromRight";
            break;
        }
            
        case HLSTransitionStyleCoverFromTopLeft: {
            return @"HLSTransitionStyleCoverFromTopLeft";
            break;
        }
            
        case HLSTransitionStyleCoverFromTopRight: {
            return @"HLSTransitionStyleCoverFromTopRight";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            return @"HLSTransitionStyleCoverFromBottomLeft";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomRight: {
            return @"HLSTransitionStyleCoverFromBottomRight";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom2: {
            return @"HLSTransitionStyleCoverFromBottom2";
            break;
        }
            
        case HLSTransitionStyleCoverFromTop2: {
            return @"HLSTransitionStyleCoverFromTop2";
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft2: {
            return @"HLSTransitionStyleCoverFromLeft2";
            break;
        }
            
        case HLSTransitionStyleCoverFromRight2: {
            return @"HLSTransitionStyleCoverFromRight2";
            break;
        }
            
        case HLSTransitionStyleCoverFromTopLeft2: {
            return @"HLSTransitionStyleCoverFromTopLeft2";
            break;
        }
            
        case HLSTransitionStyleCoverFromTopRight2: {
            return @"HLSTransitionStyleCoverFromTopRight2";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft2: {
            return @"HLSTransitionStyleCoverFromBottomLeft2";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomRight2: {
            return @"HLSTransitionStyleCoverFromBottomRight2";
            break;
        }
            
        case HLSTransitionStyleFadeIn: {
            return @"HLSTransitionStyleFadeIn";
            break;
        }
            
        case HLSTransitionStyleFadeIn2: {
            return @"HLSTransitionStyleFadeIn2";
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            return @"HLSTransitionStyleCrossDissolve";
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            return @"HLSTransitionStylePushFromBottom";
            break;
        }
            
        case HLSTransitionStylePushFromTop: {
            return @"HLSTransitionStylePushFromTop";
            break;
        }
            
        case HLSTransitionStylePushFromLeft: {
            return @"HLSTransitionStylePushFromLeft";
            break;
        }
            
        case HLSTransitionStylePushFromRight: {
            return @"HLSTransitionStylePushFromRight";
            break;
        }
            
        case HLSTransitionStyleEmergeFromCenter: {
            return @"HLSTransitionStyleEmergeFromCenter";
            break;
        }
            
        case HLSTransitionStyleFlipVertical: {
            return @"HLSTransitionStyleFlipVertical";
            break;
        }
            
        case HLSTransitionStyleFlipHorizontal: {
            return @"HLSTransitionStyleFlipHorizontal";
            break;
        }
            
        default: {
            return @"";
            break;
        }            
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HLSPlaceholderViewController";
}

@end
