//
//  ViewEffectsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/16/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "ViewEffectsDemoViewController.h"

@implementation ViewEffectsDemoViewController

#pragma mark Accessors and mutators

@synthesize imageView1 = _imageView1;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imageView1 fadeLeftBorder:100.f rightBorder:100.f];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    // Code
}

@end
