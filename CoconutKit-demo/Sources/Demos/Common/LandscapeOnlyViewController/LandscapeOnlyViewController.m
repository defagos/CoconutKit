//
//  LandscapeOnlyViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "LandscapeOnlyViewController.h"

@implementation LandscapeOnlyViewController

#pragma mark Object creation and destruction

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark Localization

- (void)localize
{
    self.title = @"LandscapeOnlyViewController";
}

@end
