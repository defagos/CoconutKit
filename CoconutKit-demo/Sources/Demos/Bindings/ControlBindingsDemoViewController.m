//
//  ControlBindingsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "ControlBindingsDemoViewController.h"

@implementation ControlBindingsDemoViewController

#pragma mark Accessors and mutators

- (NSNumber *)completion
{
    return @60.f;
}

- (NSNumber *)completionPercentage
{
    return @0.8f;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *debugOverlayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Debug", nil)
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(showBindingDebugOverlay:)];
    self.navigationItem.rightBarButtonItems = [@[debugOverlayBarButtonItem] arrayByAddingObjectsFromArray:self.navigationItem.rightBarButtonItems];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Controls", nil);
}

#pragma mark Action callbacks

- (IBAction)showBindingDebugOverlay:(id)sender
{
    [self showBindingDebugOverlayViewRecursive:YES];
}

@end
