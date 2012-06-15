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
    self.searchBar3 = nil;
}

#pragma mark Accessors and mutators

@synthesize searchBar1 = m_searchBar1;

@synthesize searchBar2 = m_searchBar2;

@synthesize searchBar3 = m_searchBar3;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start with search bar 1 expanded
    [self.searchBar1 setExpanded:YES animated:NO];
    
    self.searchBar2.alignment = HLSExpandingSearchBarAlignmentRight;
    self.searchBar2.showsBookmarkButton = YES;

    self.searchBar3.alignment = HLSExpandingSearchBarAlignmentLeft;
    self.searchBar3.showsSearchResultsButton = YES;
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
    
    self.searchBar2.placeholder = NSLocalizedString(@"Enter a search criterium", @"Enter a search criterium");
    self.searchBar2.prompt = NSLocalizedString(@"Search books", @"Search books");
    
    self.searchBar3.placeholder = NSLocalizedString(@"Enter a search criterium", @"Enter a search criterium");
    self.searchBar3.prompt = NSLocalizedString(@"Search books", @"Search books");
}

#pragma mark Action callbacks

- (IBAction)expandSearchBar1:(id)sender
{
    [self.searchBar1 setExpanded:YES animated:YES];
}

- (IBAction)collapseSearchBar1:(id)sender
{
    [self.searchBar1 setExpanded:NO animated:YES];
}

@end
