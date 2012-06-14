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
    
    self.searchBar1 = nil;
    self.searchBar2 = nil;
}

#pragma mark Accessors and mutators

@synthesize searchBar1 = m_searchBar1;

@synthesize searchBar2 = m_searchBar2;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar2.placeholder = @"Placeholder";
    self.searchBar2.prompt = @"Prompt";
    self.searchBar2.alignment = HLSExpandingSearchBarAlignmentRight;
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
