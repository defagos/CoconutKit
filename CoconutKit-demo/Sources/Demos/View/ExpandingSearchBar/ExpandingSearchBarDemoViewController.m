//
//  ExpandingSearchBarDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "ExpandingSearchBarDemoViewController.h"

@interface ExpandingSearchBarDemoViewController ()

@end

@implementation ExpandingSearchBarDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.searchBar = nil;
}

#pragma mark Accessors and mutators

@synthesize searchBar = m_searchBar;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.alignment = HLSExpandingSearchBarAlignmentRight;
    // Code
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Search bar", @"Search bar");
}

@end
