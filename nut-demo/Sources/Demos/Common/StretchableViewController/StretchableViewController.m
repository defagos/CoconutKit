//
//  StretchableViewController.m
//  nut-demo
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
    
    self.view.backgroundColor = [UIColor colorWithRed:(rand() % 256)/256.f
                                                green:(rand() % 256)/256.f 
                                                 blue:(rand() % 256)/256.f 
                                                alpha:1.f];
}

@end
