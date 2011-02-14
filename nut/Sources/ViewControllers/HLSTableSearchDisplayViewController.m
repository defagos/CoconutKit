//
//  HLSTableSearchDisplayViewController.m
//  nut
//
//  Created by Samuel Défago on 8/23/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTableSearchDisplayViewController.h"

#import "HLSReloadable.h"
#import "HLSStandardWidgetConstants.h"

@interface HLSTableSearchDisplayViewController ()

@property (nonatomic, retain) UISearchBar *searchBar;

- (void)maximizeSearchInterfaceAnimated:(BOOL)animated;
- (void)minimizeSearchInterfaceAnimated:(BOOL)animated;

- (void)reloadTable;

@end

@implementation HLSTableSearchDisplayViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Create the search bar for displaying at the top of the table view (created in init so that the user
        // has a chance to customize it before it is displayed)
        CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
        self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.f,
                                                                        0.f,
                                                                        applicationFrame.size.width, 
                                                                        kSearchBarStandardHeight)]
                          autorelease];
        self.searchBar.placeholder = NSLocalizedStringFromTable(@"Search", @"nut_Localizable", @"Search");
        self.searchBar.delegate = self;
        
        // See viewWillAppear for why this ugly boolean is currently necessary
        m_firstTime = YES;
    }
    return self;
}

- (void)dealloc
{
    self.searchDelegate = nil;
    [super dealloc];
}

- (void)releaseViews
{
    self.searchBar = nil;
    self.tableView = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // No search criterium by default. Can be customized by the delegate
    self.searchBar.text = nil;
    
    // Start with minimized search interface
    [self minimizeSearchInterfaceAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // TODO: Kind of a hack: When we enter some search criterium, browse down the list (so that the search bar is not
    //       visible anymore), then select an element and go back, the search bar has disappeared! The following line
    //       ensures it reappears again, but it sadly does not appear in the same state (e.g. if scope buttons were visible,
    //       they won't be anymore). The search criteria remain saved, though
    self.tableView.tableHeaderView = self.searchBar;
    
    // TODO: Second hack: It would make sense to define this in init (with the search bar creation) or in viewDidLoad. But no
    //       matter what, when we arrive here, the value is the maximum scope button index! Don't ask why. viewWillAppear
    //       therefore seems the only place to set it to UISegmentedControlNoSegment, but of course since this is in fact
    //       initialization code we must do it only once (otherwise we would reinitialize it each time the view reappears), 
    //       thus the ugly boolean value. Sorry.
    if (m_firstTime) {
        self.searchBar.selectedScopeButtonIndex = UISegmentedControlNoSegment;
        
        // It makes sense to clear the search string here as well
        self.tableView.tableHeaderView = self.searchBar;
        
        m_firstTime = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark Accessors and mutators

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    // Set the focus on the search interface, toggling it
    [self.searchBar becomeFirstResponder];
}

@synthesize searchBar = m_searchBar;

@synthesize tableView = m_tableView;

@synthesize searchDelegate = m_searchDelegate;

- (void)setSearchDelegate:(id <HLSTableSearchDisplayViewControllerDelegate>)searchDelegate
{
    // Check for self-assignment
    if (m_searchDelegate == searchDelegate) {
        return;
    }
    
    // Update the value
    m_searchDelegate = searchDelegate;
    
    // Cache protocol support flags
    m_flags.delegateWillBeginSearch = [m_searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerWillBeginSearch:)];
    m_flags.delegateDidBeginSearch = [m_searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerDidBeginSearch:)];
    m_flags.delegateWillEndSearch = [m_searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerWillEndSearch:)];
    m_flags.delegateDidEndSearch = [m_searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerDidEndSearch:)];
    m_flags.delegateShouldReloadTableForSearchString = [m_searchDelegate respondsToSelector:@selector(tableSearchDisplayViewController:shouldReloadTableForSearchString:)];
    m_flags.delegateShouldReloadTableForSearchScope = [m_searchDelegate respondsToSelector:@selector(tableSearchDisplayViewController:shouldReloadTableForSearchScope:)];
    m_flags.delegateShouldReloadOriginalTable = [m_searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerShouldReloadOriginalTable:)];
}

#pragma mark Search bar functions

- (void)maximizeSearchInterfaceAnimated:(BOOL)animated
{
    // Only available when wrapped into a navigation controller
    if (! self.navigationController) {
        return;
    }
    
    // Move the search bar at the top, effectively putting it where the navigation bar was located (no animation)
    [self.tableView setContentOffset:CGPointMake(0.f, 0.f) animated:NO];
    
    // "Transform" the navigation bar into the search bar with cancel button
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.searchBar setShowsCancelButton:YES animated:animated];
    
    // Display scope buttons if any
    if (self.searchBar.scopeButtonTitles) {
        // Show the (bigger) search interface
        self.searchBar.showsScopeBar = YES;
        [self.searchBar sizeToFit];
        
        // Ensure that the search interface does not overlap with the table
        // TODO: Should animate the table view downwards instead
        self.tableView.tableHeaderView = self.searchBar;
    }
}

- (void)minimizeSearchInterfaceAnimated:(BOOL)animated
{
    // Only available when wrapped into a navigation controller
    if (! self.navigationController) {
        return;
    }
    
    // "Transform" the search bar with cancel button into the navigation bar again
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    // Remove scope buttons
    if (self.searchBar.scopeButtonTitles) {
        // Shrink the search interface
        self.searchBar.showsScopeBar = NO;
        [self.searchBar sizeToFit]; 
        
        // Ensure that the search interface is at the top with no holes behind
        // TODO: Should animate the table view upwards instead
        self.tableView.tableHeaderView = self.searchBar;
    }
}

#pragma mark Reloading table view results

- (void)reloadTable
{
    if ([self conformsToProtocol:@protocol(HLSReloadable)]) {
        HLSTableSearchDisplayViewController<HLSReloadable> *reloadableTableSearchDisplayViewController = self;
        [reloadableTableSearchDisplayViewController reloadData];
    }
    else {
        [self.tableView reloadData];
    }
}

#pragma mark UISearchBarDelegate protocol implementation

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{    
    [self maximizeSearchInterfaceAnimated:YES];
    if (m_flags.delegateWillBeginSearch) {
        [self.searchDelegate tableSearchDisplayViewControllerWillBeginSearch:self];
    }
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (m_flags.delegateDidBeginSearch) {
        [self.searchDelegate tableSearchDisplayViewControllerDidBeginSearch:self];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self minimizeSearchInterfaceAnimated:YES];
    if (m_flags.delegateWillEndSearch) {
        [self.searchDelegate tableSearchDisplayViewControllerWillEndSearch:self];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (m_flags.delegateDidEndSearch) {
        [self.searchDelegate tableSearchDisplayViewControllerDidEndSearch:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (m_flags.delegateShouldReloadTableForSearchString) {
        if ([self.searchDelegate tableSearchDisplayViewController:self shouldReloadTableForSearchString:searchBar.text]) {
            [self reloadTable];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Remove keyboard from screen
    [searchBar resignFirstResponder];
    
    if (m_flags.delegateShouldReloadTableForSearchString) {
        if ([self.searchDelegate tableSearchDisplayViewController:self shouldReloadTableForSearchString:searchBar.text]) {
            [self reloadTable];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Remove keyboard from screen
    [searchBar resignFirstResponder];
    
    // Clear search criteria
    searchBar.text = nil;
    searchBar.selectedScopeButtonIndex = UISegmentedControlNoSegment;
    
    if (m_flags.delegateShouldReloadOriginalTable) {
        if ([self.searchDelegate tableSearchDisplayViewControllerShouldReloadOriginalTable:self]) {
            [self reloadTable];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if (m_flags.delegateShouldReloadTableForSearchScope) {
        if ([self.searchDelegate tableSearchDisplayViewController:self shouldReloadTableForSearchScope:selectedScope]) {
            [self reloadTable];
        }
    }
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    // To be overriden by subclasses
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // To be overriden by subclasses
    return nil;
}

@end
