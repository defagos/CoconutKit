//
//  StripsDemoViewController.m
//  nut-dev
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StripsDemoViewController.h"

@implementation StripsDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Strips", @"Strips");
    }
    return self;
}

- (void)dealloc
{
    // Code
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.stripContainerView = nil;
}

#pragma mark Accessors and mutators

@synthesize stripContainerView = m_stripContainerView;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stripContainerView.positions = 6;
    [self.stripContainerView addStripAtPosition:0 length:1];
    [self.stripContainerView addStripAtPosition:3 length:2];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

@end
