//
//  HeavyViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HeavyViewController.h"

@implementation HeavyViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Simulate heavy view loading by waiting two seconds
    [NSThread sleepForTimeInterval:2.];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HeavyViewController";
}

@end
