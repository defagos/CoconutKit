//
//  SegueStackOtherDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.06.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "SegueStackOtherDemoViewController.h"

#import "MemoryWarningTestCoverViewController.h"

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
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[MemoryWarningTestCoverViewController alloc] init];
    [self presentViewController:memoryWarningTestCoverViewController animated:YES completion:nil];
}

@end
