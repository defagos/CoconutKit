//
//  ControlBindingsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "ControlBindingsDemoViewController.h"

@interface ControlBindingsDemoViewController ()

@property (nonatomic, strong) NSNumber *switchEnabled;

@end

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

- (NSNumber *)category
{
    return @1;
}

- (NSString *)name
{
    return @"CoconutKit";
}

- (NSString *)summary
{
    return @"CoconutKit is a library of high-quality iOS components written at hortis le studio and in my spare time. It includes several tools for dealing with view controllers, multi-threading, animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.";
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
