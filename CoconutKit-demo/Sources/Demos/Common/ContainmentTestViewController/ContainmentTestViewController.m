//
//  ContainmentTestViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 8/10/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "ContainmentTestViewController.h"

#import "MemoryWarningTestCoverViewController.h"

@implementation ContainmentTestViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    // It is sufficient to log this information once, it won't change afterwards
    HLSLoggerInfo(@"navigationController = %@"
                  "\n\ttabBarController = %@"
                  "\n\tstackController = %@"
                  "\n\tplaceholderViewController = %@"
                  "\n\tparentViewController = %@"
                  "\n\tmodalViewController = %@",
                  self.navigationController,
                  self.tabBarController,
                  self.stackController,
                  self.placeholderViewController,
                  self.parentViewController,
                  self.modalViewController);
    
    // iOS 5 only (warning: presentedViewController existed before iOS 5 as private method, must test presentingViewController
    // for which it was not the case)
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        HLSLoggerInfo(@"(iOS 5) presentedViewController = %@"
                      "\n\tpresentingViewController = %@",
                      self.presentedViewController,
                      self.presentingViewController);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Can be called also in iOS 4 thanks to CoconutKit
    HLSLoggerInfo(@"isMovingToParentViewController = %@", HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Can be called also in iOS 4 thanks to CoconutKit
    HLSLoggerInfo(@"isMovingToParentViewController = %@", HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Can be called also in iOS 4 thanks to CoconutKit
    HLSLoggerInfo(@"isMovingFromParentViewController = %@", HLSStringFromBool([self isMovingFromParentViewController]));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Can be called also in iOS 4 thanks to CoconutKit
    HLSLoggerInfo(@"isMovingFromParentViewController = %@", HLSStringFromBool([self isMovingFromParentViewController]));
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
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"interfaceOrientation = %@", HLSStringFromInterfaceOrientation(self.interfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"interfaceOrientation = %@", HLSStringFromInterfaceOrientation(self.interfaceOrientation));
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"ContainmentTestViewController";
}

#pragma mark Action callbacks

- (IBAction)hideWithModal:(id)sender
{
    // Just to test -parentViewController (if correct, then the topmost container will be presenting the modal)
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    [self presentModalViewController:memoryWarningTestCoverViewController animated:YES];
}

@end
