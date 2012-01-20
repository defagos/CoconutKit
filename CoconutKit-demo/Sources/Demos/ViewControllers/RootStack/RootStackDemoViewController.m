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

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];

    self.popButton = nil;
    self.transitionPickerView = nil;
}

#pragma mark Accessors and mutators

@synthesize popButton = m_popButton;

@synthesize transitionPickerView = m_transitionPickerView;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
        
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
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
            
        case HLSTransitionStyleFadeIn: {
            return @"HLSTransitionStyleFadeIn";
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
    [self.stackController pushViewController:viewController withTransitionStyle:pickedIndex];
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
        [self.stackController popViewController];
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
    [self presentModalViewController:memoryWarningTestCoverViewController animated:YES];
}

- (void)closeNativeContainer:(id)sender
{
    [self.stackController popViewController];
}

@end
