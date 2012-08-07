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
        stackController.delegate = self;
        stackController.title = @"HLSStackController";
        
        // Pre-load other view controllers before display. Yep, this is possible!
        UIViewController *firstViewController = [[[TransparentViewController alloc] init] autorelease];
        [stackController pushViewController:firstViewController 
                        withTransitionStyle:HLSTransitionStyleEmergeFromCenter
                                   animated:NO];
        UIViewController *secondViewController = [[[TransparentViewController alloc] init] autorelease];
        [stackController pushViewController:secondViewController 
                        withTransitionStyle:HLSTransitionStylePushFromRight
                                   animated:NO];
        UIViewController *thirdViewController = [[[TransparentViewController alloc] init] autorelease];
        [stackController pushViewController:thirdViewController 
                        withTransitionStyle:HLSTransitionStyleCoverFromRight2
                                   animated:NO];
        UIViewController *fourthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:fourthViewController 
                        withTransitionStyle:HLSTransitionStyleCoverFromBottom
                                   animated:NO];
        UIViewController *fifthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:fifthViewController 
                        withTransitionStyle:HLSTransitionStylePushFromTop
                                   animated:NO];
        UIViewController *sixthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:sixthViewController
                        withTransitionStyle:HLSTransitionStyleFlipHorizontal
                                   animated:NO];
        
        
        [self setInsetViewController:stackController atIndex:0];
        self.forwardingProperties = YES;
    }
    return self;
}

- (void)releaseViews
{ 
    [super releaseViews];
    
    self.transitionPickerView = nil;
    self.inTabBarControllerSwitch = nil;
    self.inNavigationControllerSwitch = nil;
    self.forwardingPropertiesSwitch = nil;
    self.animatedSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize inTabBarControllerSwitch = m_inTabBarControllerSwitch;

@synthesize inNavigationControllerSwitch = m_inNavigationControllerSwitch;

@synthesize forwardingPropertiesSwitch = m_forwardingPropertiesSwitch;

@synthesize animatedSwitch = m_animatedSwitch;

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
    
    // We can even embed navigation and tab bar controllers within a placeolder view controller!
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
    [stackController pushViewController:pushedViewController
                    withTransitionStyle:pickedIndex
                               animated:self.animatedSwitch.on];
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
    [stackController popViewControllerAnimated:self.animatedSwitch.on];
}

- (IBAction)popToRoot:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    [stackController popToRootViewControllerAnimated:self.animatedSwitch.on];
}

- (IBAction)popThree:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    NSArray *viewControllers = [stackController viewControllers];
    UIViewController *targetViewController = nil;
    if ([viewControllers count] >= 4) {
        targetViewController = [viewControllers objectAtIndex:[viewControllers count] - 4];
    }
    else {
        targetViewController = [stackController rootViewController];
    }
    [stackController popToViewController:targetViewController animated:self.animatedSwitch.on];
}

- (IBAction)toggleForwardingProperties:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    stackController.forwardingProperties = self.forwardingPropertiesSwitch.on;
}

- (IBAction)navigateForwardNonAnimated:(id)sender
{
    StackDemoViewController *stackDemoViewController = [[[StackDemoViewController alloc] init] autorelease];
    [self.navigationController pushViewController:stackDemoViewController animated:NO];
}

- (IBAction)navigateBackNonAnimated:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark HLSStackControllerDelegate protocol implementation

- (void)stackController:(HLSStackController *)stackController
 willShowViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
  didShowViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
 willHideViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will hide view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
  didHideViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did hide view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
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
            
        case HLSTransitionStylePushFromBottomFadeIn: {
            return @"HLSTransitionStylePushFromBottomFadeIn";
            break;
        }
            
        case HLSTransitionStylePushFromTopFadeIn: {
            return @"HLSTransitionStylePushFromTopFadeIn";
            break;
        }
            
        case HLSTransitionStylePushFromLeftFadeIn: {
            return @"HLSTransitionStylePushFromLeftFadeIn";
            break;
        }
            
        case HLSTransitionStylePushFromRightFadeIn: {
            return @"HLSTransitionStylePushFromRightFadeIn";
            break;
        }
            
        case HLSTransitionStyleFlowFromBottom: {
            return @"HLSTransitionStyleFlowFromBottom";
            break;
        }
            
        case HLSTransitionStyleFlowFromTop: {
            return @"HLSTransitionStyleFlowFromTop";
            break;
        }
            
        case HLSTransitionStyleFlowFromLeft: {
            return @"HLSTransitionStyleFlowFromLeft";
            break;
        }
            
        case HLSTransitionStyleFlowFromRight: {
            return @"HLSTransitionStyleFlowFromRight";
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
