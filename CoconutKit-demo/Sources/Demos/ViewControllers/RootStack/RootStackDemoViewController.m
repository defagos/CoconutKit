//
//  RootStackDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "RootStackDemoViewController.h"

#import "MemoryWarningTestCoverViewController.h"
#import "StretchableViewController.h"

@interface RootStackDemoViewController ()

- (void)displayViewController:(UIViewController *)viewController;

- (void)closeNativeContainer:(id)sender;

@end

@implementation RootStackDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.backBarButtonItem = nil;
    self.actionSheetBarButtonItem = nil;
    self.popButton = nil;
    
    // Avoid a crash when popping a view controller in the root stack demo in the iOS simulator (no crash on the device). This
    // seems related to the accessibility inspector feature of the iOS simulator
    self.transitionPickerView.dataSource = nil;
    self.transitionPickerView.delegate = nil;
    
    self.transitionPickerView = nil;
    self.animatedSwitch = nil;
    self.autorotationModeSegmentedControl = nil;
    self.portraitSwitch = nil;
    self.landscapeRightSwitch = nil;
    self.landscapeLeftSwitch = nil;
    self.portraitUpsideDownSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize backBarButtonItem = m_backBarButtonItem;

@synthesize actionSheetBarButtonItem = m_actionSheetBarButtonItem;

@synthesize popButton = m_popButton;

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize animatedSwitch = m_animatedSwitch;

@synthesize portraitSwitch = m_portraitSwitch;

@synthesize landscapeRightSwitch = m_landscapeRightSwitch;

@synthesize landscapeLeftSwitch = m_landscapeLeftSwitch;

@synthesize portraitUpsideDownSwitch = m_portraitUpsideDownSwitch;

@synthesize autorotationModeSegmentedControl = m_autorotationModeSegmentedControl;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
        
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    self.portraitSwitch.on = YES;
    self.landscapeRightSwitch.on = YES;
    self.landscapeLeftSwitch.on = YES;
    self.portraitUpsideDownSwitch.on = YES;
    
    self.autorotationModeSegmentedControl.selectedSegmentIndex = self.stackController.autorotationMode;
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingToParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingToParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingFromParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingFromParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)viewWillUnload
{
    [super viewWillUnload];
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    HLSLoggerInfo(@"Called for object %@", self);
}

#pragma mark Containment

- (void)willMoveToParentViewController:(UIViewController *)parentViewController
{
    [super willMoveToParentViewController:parentViewController];
    
    HLSLoggerInfo(@"Called for object %@, parent is %@", self, parentViewController);
}

- (void)didMoveToParentViewController:(UIViewController *)parentViewController
{
    [super didMoveToParentViewController:parentViewController];
    
    HLSLoggerInfo(@"Called for object %@, parent is %@", self, parentViewController);
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    HLSLoggerInfo(@"Called");
    
    return [super shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    HLSLoggerInfo(@"Called");
    
    NSUInteger supportedOrientations = 0;
    if ([self isViewLoaded]) {
        if (self.portraitSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskPortrait;
        }
        if (self.landscapeRightSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskLandscapeRight;
        }
        if (self.landscapeLeftSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskLandscapeLeft;
        }
        if (self.portraitUpsideDownSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
        }
    }
    else {
        supportedOrientations = UIInterfaceOrientationMaskAll;
    }
    
    return [super supportedInterfaceOrientations] & supportedOrientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called for object %@, toInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@", self,
                  HLSStringFromInterfaceOrientation(toInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called for object %@, toInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@", self,
                  HLSStringFromInterfaceOrientation(toInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"Called for object %@, fromInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@", self,
                  HLSStringFromInterfaceOrientation(fromInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.backBarButtonItem.title = HLSLocalizedStringFromUIKit(@"Back");
    self.actionSheetBarButtonItem.title = NSLocalizedString(@"Action sheet", @"Action sheet");
    
    if (self == [self.stackController rootViewController]) {
        [self.popButton setTitle:NSLocalizedString(@"Close", @"Close") forState:UIControlStateNormal];
    }
    else {
        [self.popButton setTitle:NSLocalizedString(@"Pop", @"Pop") forState:UIControlStateNormal];
    }
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

#pragma mark Displaying view controllers

- (void)displayViewController:(UIViewController *)viewController
{
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    NSString *transitionName = [[HLSTransition availableTransitionNames] objectAtIndex:pickedIndex];
    [self.stackController pushViewController:viewController
                         withTransitionClass:NSClassFromString(transitionName)
                                    animated:self.animatedSwitch.on];
}

#pragma mark Event callbacks

- (IBAction)push:(id)sender
{
    RootStackDemoViewController *demoViewController = [[[RootStackDemoViewController alloc] init] autorelease];
    [self displayViewController:demoViewController];
}

- (IBAction)pop:(id)sender
{
    if (self == [self.stackController rootViewController]) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.stackController popViewControllerAnimated:self.animatedSwitch.on];
    }
}

- (IBAction)pushTabBarController:(id)sender
{
    StretchableViewController *stretchableViewController = [[[StretchableViewController alloc] init] autorelease];
    stretchableViewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close")
                                                                                                   style:UIBarButtonItemStyleDone 
                                                                                                  target:self 
                                                                                                  action:@selector(closeNativeContainer:)] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:stretchableViewController] autorelease];
    navigationController.autorotationMode = HLSAutorotationModeContainerAndTopChildren;
    UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
    tabBarController.viewControllers = [NSArray arrayWithObject:navigationController];
    [self displayViewController:tabBarController];    
}

- (IBAction)pushNavigationController:(id)sender
{
    StretchableViewController *stretchableViewController = [[[StretchableViewController alloc] init] autorelease];
    stretchableViewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close")
                                                                                                   style:UIBarButtonItemStyleDone 
                                                                                                  target:self 
                                                                                                  action:@selector(closeNativeContainer:)] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:stretchableViewController] autorelease];
    navigationController.autorotationMode = HLSAutorotationModeContainerAndTopChildren;
    [self displayViewController:navigationController];
}

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    memoryWarningTestCoverViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:memoryWarningTestCoverViewController animated:YES];
}

- (IBAction)showActionSheet:(id)sender
{
    // Just to test behavior during pop
    HLSActionSheet *actionSheet = [[[HLSActionSheet alloc] init] autorelease];
    [actionSheet addButtonWithTitle:@"1"
                             target:self
                             action:NULL];
    [actionSheet addButtonWithTitle:@"2"
                             target:self
                             action:NULL];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") target:self action:NULL];
    }
    
    [actionSheet showFromBarButtonItem:self.actionSheetBarButtonItem animated:YES];
}

- (void)closeNativeContainer:(id)sender
{
    [self.stackController popViewControllerAnimated:YES];
}

- (IBAction)changeAutorotationMode:(id)sender
{
    self.stackController.autorotationMode = self.autorotationModeSegmentedControl.selectedSegmentIndex;
}

@end
