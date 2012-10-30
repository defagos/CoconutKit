//
//  RootNavigationDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10/29/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "RootNavigationDemoViewController.h"

#import "MemoryWarningTestCoverViewController.h"

@implementation RootNavigationDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.portraitSwitch = nil;
    self.landscapeRightSwitch = nil;
    self.landscapeLeftSwitch = nil;
    self.portraitUpsideDownSwitch = nil;
    self.autorotationModeSegmentedControl = nil;
}

#pragma mark Accessors and mutators

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
    
    self.portraitSwitch.on = YES;
    self.landscapeRightSwitch.on = YES;
    self.landscapeLeftSwitch.on = YES;
    self.portraitUpsideDownSwitch.on = YES;
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@", self, HLSStringFromBool(animated),
                  HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@", self, HLSStringFromBool(animated),
                  HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@", self, HLSStringFromBool(animated),
                  HLSStringFromBool([self isMovingFromParentViewController]));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@", self, HLSStringFromBool(animated),
                  HLSStringFromBool([self isMovingFromParentViewController]));
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

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    HLSLoggerInfo(@"Called");
    
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    HLSLoggerInfo(@"Called");
    
    NSUInteger supportedOrientations = 0;
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
    
    return [super supportedInterfaceOrientations] & supportedOrientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called, toInterfaceOrientation = %@", HLSStringFromInterfaceOrientation(toInterfaceOrientation));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called, toInterfaceOrientation = %@", HLSStringFromInterfaceOrientation(toInterfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"Called, fromInterfaceOrientation = %@", HLSStringFromInterfaceOrientation(fromInterfaceOrientation));
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"RootNavigationDemoViewController";
    
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"Container", @"Container") forSegmentAtIndex:0];
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"No children", @"No children") forSegmentAtIndex:1];
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"Visible", @"Visible") forSegmentAtIndex:2];
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"All", @"All") forSegmentAtIndex:3];
}

#pragma mark Action callbacks

- (IBAction)push:(id)sender
{
    RootNavigationDemoViewController *rootNavigationDemoViewController = [[[RootNavigationDemoViewController alloc] init] autorelease];
    [self.navigationController pushViewController:rootNavigationDemoViewController animated:YES];
}

- (IBAction)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    [self presentModalViewController:memoryWarningTestCoverViewController animated:YES];
}

- (IBAction)changeAutorotationMode:(id)sender
{
    self.navigationController.autorotationMode = self.autorotationModeSegmentedControl.selectedSegmentIndex;
}

@end
