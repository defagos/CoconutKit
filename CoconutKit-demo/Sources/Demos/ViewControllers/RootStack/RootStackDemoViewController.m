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

#pragma mark Displaying view controllers

- (void)displayViewController:(UIViewController *)viewController
{
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    [self.stackController pushViewController:viewController withTransitionStyle:pickedIndex animated:self.animatedSwitch.on];
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
