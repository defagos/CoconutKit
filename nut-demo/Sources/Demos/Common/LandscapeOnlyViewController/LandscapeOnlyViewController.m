//
//  LandscapeOnlyViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "LandscapeOnlyViewController.h"

@implementation LandscapeOnlyViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = @"LandscapeOnlyViewController";
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:(rand() % 256)/256.f
                                                green:(rand() % 256)/256.f 
                                                 blue:(rand() % 256)/256.f 
                                                alpha:1.f];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
