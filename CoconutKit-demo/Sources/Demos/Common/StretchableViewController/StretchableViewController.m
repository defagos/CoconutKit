//
//  StretchableViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StretchableViewController.h"

@implementation StretchableViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"StretchableViewController";
}

@end
