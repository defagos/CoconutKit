//
//  TransparentViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TransparentViewController.h"

@implementation TransparentViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor randomColor];
    self.view.alpha = 0.5f;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"TransparentViewController";
}

@end
