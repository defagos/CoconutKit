//
//  ExpandingSearchBarDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "ExpandingSearchBarDemoViewController.h"

@interface ExpandingSearchBarDemoViewController ()

@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar1;
@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar2;
@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar3;

@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;

@end

@implementation ExpandingSearchBarDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.searchBar1 = nil;
    self.searchBar2 = nil;
    self.searchBar3 = nil;
    self.animatedSwitch = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animatedSwitch.on = YES;
    
    // Start with search bar 1 expanded
    [self.searchBar1 setExpanded:YES animated:NO];
    self.searchBar1.delegate = self;
    
    self.searchBar2.alignment = HLSExpandingSearchBarAlignmentRight;
    self.searchBar2.showsBookmarkButton = YES;
    self.searchBar2.delegate = self;

    self.searchBar3.alignment = HLSExpandingSearchBarAlignmentLeft;
    self.searchBar3.showsSearchResultsButton = YES;
    self.searchBar3.delegate = self;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Search bar", nil);
    
    self.searchBar2.placeholder = NSLocalizedString(@"Enter a search criterium", nil);
    self.searchBar2.prompt = NSLocalizedString(@"Search books", nil);
    
    self.searchBar3.placeholder = NSLocalizedString(@"Enter a search criterium", nil);
    self.searchBar3.prompt = NSLocalizedString(@"Search books", nil);
}

#pragma mark HLSExpandingSearchBarDelegate protocol implementation

- (void)expandingSearchBarDidExpand:(HLSExpandingSearchBar *)searchBar animated:(BOOL)animated
{
    HLSLoggerInfo(@"Search bar did expand, animated = %@", HLSStringFromBool(animated));
}

- (void)expandingSearchBarDidCollapse:(HLSExpandingSearchBar *)searchBar animated:(BOOL)animated
{
    HLSLoggerInfo(@"Search bar did collapse, animated = %@", HLSStringFromBool(animated));
}

- (BOOL)expandingSearchBarShouldBeginEditing:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar should begin editing");
    return YES;
}

- (void)expandingSearchBarTextDidBeginEditing:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar text did begin editing");
}

- (BOOL)expandingSearchBarShouldEndEditing:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar should end editing");
    return YES;
}

- (void)expandingSearchBarTextDidEndEditing:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar text did end editing");
}

- (void)expandingSearchBar:(HLSExpandingSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    HLSLoggerInfo(@"Search bar text did change: %@", searchText);
}

- (BOOL)expandingSearchBar:(HLSExpandingSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    HLSLoggerInfo(@"Search bar should change text with replacement text %@", text);
    return YES;
}

- (void)expandingSearchBarSearchButtonClicked:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar search button clicked");
}

- (void)expandingSearchBarBookmarkButtonClicked:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar bookmark button clicked");
}

- (void)expandingSearchBarCancelButtonClicked:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar cancel button clicked");
}

- (void)expandingSearchBarResultsListButtonClicked:(HLSExpandingSearchBar *)searchBar
{
    HLSLoggerInfo(@"Search bar search button clicked");
}

#pragma mark Action callbacks

- (IBAction)expandSearchBar1:(id)sender
{
    [self.searchBar1 setExpanded:YES animated:self.animatedSwitch.on];
    [self.searchBar2 setExpanded:YES animated:self.animatedSwitch.on];
    [self.searchBar3 setExpanded:YES animated:self.animatedSwitch.on];
}

- (IBAction)collapseSearchBar1:(id)sender
{
    [self.searchBar1 setExpanded:NO animated:self.animatedSwitch.on];
    [self.searchBar2 setExpanded:NO animated:self.animatedSwitch.on];
    [self.searchBar3 setExpanded:NO animated:self.animatedSwitch.on];
}

@end
