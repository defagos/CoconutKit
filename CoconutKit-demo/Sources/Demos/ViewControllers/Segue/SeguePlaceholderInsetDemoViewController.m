//
//  SeguePlaceholderInsetDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 29.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "SeguePlaceholderInsetDemoViewController.h"

@implementation SeguePlaceholderInsetDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & HLSInterfaceOrientationMaskAll;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    // Just to suppress localization warnings
}

@end
