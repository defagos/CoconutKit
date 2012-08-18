//
//  StackDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StackDemoViewController.h"

#import "ContainmentTestViewController.h"
#import "FixedSizeViewController.h"
#import "HeavyViewController.h"
#import "LandscapeOnlyViewController.h"
#import "LifeCycleTestViewController.h"
#import "MemoryWarningTestCoverViewController.h"
#import "PortraitOnlyViewController.h"
#import "RootStackDemoViewController.h"
#import "StretchableViewController.h"
#import "TransparentViewController.h"

@interface StackDemoViewController ()

- (void)displayContentViewController:(UIViewController *)viewController;

- (void)updateIndexInfo;
- (NSUInteger)insertionIndex;
- (NSUInteger)removalIndex;

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
                        withTransitionClass:[HLSTransitionEmergeFromCenter class]
                                   animated:NO];
        UIViewController *secondViewController = [[[TransparentViewController alloc] init] autorelease];
        [stackController pushViewController:secondViewController 
                        withTransitionClass:[HLSTransitionPushFromRight class]
                                   animated:NO];
        UIViewController *thirdViewController = [[[TransparentViewController alloc] init] autorelease];
        [stackController pushViewController:thirdViewController 
                        withTransitionClass:[HLSTransitionCoverFromRightPushToBack class]
                                   animated:NO];
        UIViewController *fourthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:fourthViewController 
                        withTransitionClass:[HLSTransitionCoverFromBottom class]
                                   animated:NO];
        UIViewController *fifthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:fifthViewController 
                        withTransitionClass:[HLSTransitionPushFromTop class]
                                   animated:NO];
        UIViewController *sixthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:sixthViewController
                        withTransitionClass:[HLSTransitionFlipHorizontal class]
                                   animated:NO];
        
        [self setInsetViewController:stackController atIndex:0];
    }
    return self;
}

- (void)releaseViews
{ 
    [super releaseViews];
    
    self.transitionPickerView = nil;
    self.inTabBarControllerSwitch = nil;
    self.inNavigationControllerSwitch = nil;
    self.animatedSwitch = nil;
    self.indexSlider = nil;
    self.insertionIndexLabel = nil;
    self.removalIndexLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize inTabBarControllerSwitch = m_inTabBarControllerSwitch;

@synthesize inNavigationControllerSwitch = m_inNavigationControllerSwitch;

@synthesize animatedSwitch = m_animatedSwitch;

@synthesize indexSlider = m_indexSlider;

@synthesize insertionIndexLabel = m_insertionIndexLabel;

@synthesize removalIndexLabel = m_removalIndexLabel;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    self.inTabBarControllerSwitch.on = NO;
    self.inNavigationControllerSwitch.on = NO;
    
    self.indexSlider.minimumValue = 1.f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateIndexInfo];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HLSStackController";
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
    NSString *transitionName = [[HLSTransition availableTransitionNames] objectAtIndex:pickedIndex];
    [stackController insertViewController:viewController
                                  atIndex:(NSUInteger)roundf(self.indexSlider.value)
                      withTransitionClass:NSClassFromString(transitionName)
                                 duration:kAnimationTransitionDefaultDuration
                                 animated:YES];
    
    [self updateIndexInfo];
}

#pragma mark Miscellaneous

- (void)updateIndexInfo
{
    HLSStackController *stackController = (HLSStackController *)[self insetViewControllerAtIndex:0];
    self.indexSlider.maximumValue = [stackController count];
    self.indexSlider.value = [stackController count];
    [self indexChanged:self.indexSlider];
}

- (NSUInteger)insertionIndex
{
    return roundf(self.indexSlider.value);
}

- (NSUInteger)removalIndex
{
    return MIN([self insertionIndex], [self.indexSlider maximumValue] - 1);
}

#pragma mark HLSStackControllerDelegate protocol implementation

- (void)stackController:(HLSStackController *)stackController
 willPushViewController:(UIViewController *)pushedViewController
    coverViewController:(UIViewController *)coveredViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will push view controller %@, cover view controller %@, animated = %@", pushedViewController, coveredViewController, HLSStringFromBool(animated));
}

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
    
    [self updateIndexInfo];
}

- (void)stackController:(HLSStackController *)stackController
  didPushViewController:(UIViewController *)pushedViewController
    coverViewController:(UIViewController *)coveredViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did push view controller %@, cover view controller %@, animated = %@", pushedViewController, coveredViewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
  willPopViewController:(UIViewController *)poppedViewController
   revealViewController:(UIViewController *)revealedViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will pop view controller %@, reveal view controller %@, animated = %@", poppedViewController, revealedViewController, HLSStringFromBool(animated));
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

- (void)stackController:(HLSStackController *)stackController
   didPopViewController:(UIViewController *)poppedViewController
   revealViewController:(UIViewController *)revealedViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did pop view controller %@, reveal view controller %@, animated = %@", poppedViewController, revealedViewController, HLSStringFromBool(animated));
    
    [self updateIndexInfo];
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
    LifeCycleTestViewController *lifecycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
    [self displayContentViewController:lifecycleTestViewController];
}

- (IBAction)displayContainmentTest:(id)sender
{
    ContainmentTestViewController *containmentTestViewController = [[[ContainmentTestViewController alloc] init] autorelease];
    [self displayContentViewController:containmentTestViewController];
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

- (IBAction)displayHeavy:(id)sender
{
    HeavyViewController *heavyViewController = [[[HeavyViewController alloc] init] autorelease];
    [self displayContentViewController:heavyViewController];
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

- (IBAction)displayTransparent:(id)sender
{
    TransparentViewController *transparentViewController = [[[TransparentViewController alloc] init] autorelease];
    [self displayContentViewController:transparentViewController];
}

- (IBAction)testInModal:(id)sender
{
    RootStackDemoViewController *rootStackDemoViewController = [[[RootStackDemoViewController alloc] init] autorelease];
    HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootStackDemoViewController] autorelease];
    // Benefits from the fact that we are already logging HLSStackControllerDelegate methods in this class
    stackController.delegate = self;
    [self presentModalViewController:stackController animated:YES];
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

- (IBAction)indexChanged:(id)sender
{
    self.insertionIndexLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Insertion index: %d", @"Insertion index: %d"),
                                     [self insertionIndex]];
    self.removalIndexLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Removal index: %d", @"Removal index: %d"),
                                   [self removalIndex]];
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

@end
