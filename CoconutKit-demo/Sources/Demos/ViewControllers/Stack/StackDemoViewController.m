//
//  StackDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StackDemoViewController.h"

#import "ContainerCustomizationViewController.h"
#import "FixedSizeViewController.h"
#import "LandscapeOnlyViewController.h"
#import "LifeCycleTestViewController.h"
#import "MemoryWarningTestCoverViewController.h"
#import "OrientationClonerViewController.h"
#import "PortraitOnlyViewController.h"
#import "StretchableViewController.h"
#import "TransparentViewController.h"
#import "RootStackDemoViewController.h"

@interface StackDemoViewController ()

- (void)displayContentViewController:(UIViewController *)viewController;

@end

@implementation StackDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        UIViewController *rootViewController = [[[LifeCycleTestViewController alloc] init] autorelease];        
        HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootViewController] autorelease];
        stackController.title = @"HLSStackController";
        
        // Pre-load other view controllers before display. Yep, this is possible!
        UIViewController *firstViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:firstViewController withTransitionStyle:HLSTransitionStyleEmergeFromCenter];
        UIViewController *secondViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:secondViewController withTransitionStyle:HLSTransitionStylePushFromRight];
        UIViewController *thirdViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:thirdViewController withTransitionStyle:HLSTransitionStyleCoverFromRight2];
        UIViewController *fourthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:fourthViewController withTransitionStyle:HLSTransitionStyleCoverFromBottom];
        UIViewController *fifthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:fifthViewController withTransitionStyle:HLSTransitionStylePushFromTop];
        UIViewController *sixthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:sixthViewController withTransitionStyle:HLSTransitionStyleFlipHorizontal];
        
        [self setInsetViewController:stackController atIndex:0];
        self.forwardingProperties = YES;
    }
    return self;
}

- (void)releaseViews
{ 
    [super releaseViews];
    
    self.transitionPickerView = nil;
    self.forwardingPropertiesSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize inTabBarControllerSwitch = m_inTabBarControllerSwitch;

@synthesize inNavigationControllerSwitch = m_inNavigationControllerSwitch;

@synthesize forwardingPropertiesSwitch = m_forwardingPropertiesSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    
    self.inTabBarControllerSwitch.on = NO;
    self.inNavigationControllerSwitch.on = NO;
    self.forwardingPropertiesSwitch.on = stackController.forwardingProperties;
}

#pragma mark Displaying a view controller according to the user settings

- (void)displayContentViewController:(UIViewController *)viewController
{
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    
    // We can even embbed navigation and tab bar controllers within a placeolder view controller!
    UIViewController *pushedViewController = viewController;
    if (pushedViewController) {
        if (self.inNavigationControllerSwitch.on) {
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:pushedViewController] autorelease];
            pushedViewController = navigationController;
        }
        if (self.inTabBarControllerSwitch.on) {
            UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
            tabBarController.viewControllers = [NSArray arrayWithObject:pushedViewController];
            pushedViewController = tabBarController;
        }    
    }
    
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    [stackController pushViewController:pushedViewController withTransitionStyle:pickedIndex];
}

#pragma mark Event callbacks

- (IBAction)displayLifeCycleTest:(id)sender
{
    LifeCycleTestViewController *lifecycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
    [self displayContentViewController:lifecycleTestViewController];
}

- (IBAction)displayStretchable:(id)sender
{
    StretchableViewController *stretchableViewController = [[[StretchableViewController alloc] init] autorelease];
    [self displayContentViewController:stretchableViewController];
}

- (IBAction)displayFixedSize:(id)sender
{
    FixedSizeViewController *fixedSizeViewController = [[[FixedSizeViewController alloc] init] autorelease];
    [self displayContentViewController:fixedSizeViewController];
}

- (IBAction)displayPortraitOnly:(id)sender
{
    PortraitOnlyViewController *portraitOnlyViewController = [[[PortraitOnlyViewController alloc] init] autorelease];
    [self displayContentViewController:portraitOnlyViewController];
}

- (IBAction)displayLandscapeOnly:(id)sender
{
    LandscapeOnlyViewController *landscapeOnlyViewController = [[[LandscapeOnlyViewController alloc] init] autorelease];
    [self displayContentViewController:landscapeOnlyViewController];
}

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    [self presentModalViewController:memoryWarningTestCoverViewController animated:YES];
}

- (IBAction)displayOrientationCloner:(id)sender
{
    OrientationClonerViewController *orientationClonerViewController = [[[OrientationClonerViewController alloc] 
                                                                         initWithPortraitOrientation:UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
                                                                         large:NO]
                                                                        autorelease];
    [self displayContentViewController:orientationClonerViewController];
}

- (IBAction)displayTransparent:(id)sender
{
    TransparentViewController *transparentViewController = [[[TransparentViewController alloc] init] autorelease];
    [self displayContentViewController:transparentViewController];
}

- (IBAction)testInModal:(id)sender
{
    RootStackDemoViewController *rootStackDemoViewController = [[[RootStackDemoViewController alloc] init] autorelease];
    HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootStackDemoViewController] autorelease];
    [self presentModalViewController:stackController animated:YES];
}

- (IBAction)displayContainerCustomization:(id)sender
{
    ContainerCustomizationViewController *containerCustomizationViewController = [[[ContainerCustomizationViewController alloc] init] autorelease];
    [self displayContentViewController:containerCustomizationViewController];
}

- (IBAction)pop:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    [stackController popViewController];
}

- (IBAction)toggleForwardingProperties:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    stackController.forwardingProperties = self.forwardingPropertiesSwitch.on;
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
    
    // Just to suppress localization warning
}

@end
