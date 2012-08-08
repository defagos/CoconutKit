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
    self.transitionPickerView = nil;
    self.animatedSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize backBarButtonItem = m_backBarButtonItem;

@synthesize actionSheetBarButtonItem = m_actionSheetBarButtonItem;

@synthesize popButton = m_popButton;

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize animatedSwitch = m_animatedSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
        
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    HLSLoggerInfo(@"Called for object %@", self);
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
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

@end
