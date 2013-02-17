//
//  SegueStackOtherDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "SegueStackOtherDemoViewController.h"

#import "MemoryWarningTestCoverViewController.h"

@interface SegueStackOtherDemoViewController ()

- (IBAction)hideWithModal:(id)sender;
- (IBAction)pop:(id)sender;

@end

@implementation SegueStackOtherDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Action callbacks

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    [self presentModalViewController:memoryWarningTestCoverViewController animated:YES];
}

- (IBAction)pop:(id)sender
{
    // Segues can only be used for view controller insertion. Removal must be done programmatically
    [self.stackController popViewControllerAnimated:YES];
}

@end
