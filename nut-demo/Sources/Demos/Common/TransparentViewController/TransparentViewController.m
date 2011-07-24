//
//  TransparentViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TransparentViewController.h"

@implementation TransparentViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = @"TransparentViewController";
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor randomColor];
    self.view.alpha = 0.5f;
}

@end
