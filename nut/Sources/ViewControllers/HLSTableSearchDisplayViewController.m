//
//  HLSTableSearchDisplayViewController.m
//  nut
//
//  Created by Samuel Défago on 8/23/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTableSearchDisplayViewController.h"

#import "HLSRuntimeChecks.h"
#import "HLSStandardWidgetConstants.h"

@interface HLSTableSearchDisplayViewController ()

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) UISearchDisplayController *searchController;      // Not called searchDisplayController to avoid conflicts with 
                                                                                // UIViewController's searchViewController property
@end

@implementation HLSTableSearchDisplayViewController

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.searchText = nil;
    self.searchController = nil;
    self.searchDelegate = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.searchBar = nil;
    self.tableView = nil;
}

#pragma mark Accessors and mutators

@synthesize searchBar = m_searchBar;

@synthesize tableView = m_tableView;

- (UITableView *)searchResultsTableView
{
    return self.searchController.searchResultsTableView;
}

@synthesize searchText = m_searchText;

@synthesize searchController = m_searchController;

@synthesize searchDelegate = m_searchDelegate;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the search bar for displaying at the top of the table view (created at initialization time so that it
    // can be further customized by the subclass viewDidLoad method)
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.f,
                                                                    0.f,
                                                                    applicationFrame.size.width, 
                                                                    kSearchBarStandardHeight)]
                      autorelease];
    
    // Manage the search interface using the built-in UISearchDisplayController. We therefore benefit from its
    // features (animations, dimming view, navigation controller dedicated support, etc.) for free
    self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar 
                                                               contentsController:self] 
                             autorelease];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
    // The search bar is added as table view header. I initially planned to give maximum flexibility (a rw searchBar property
    // outlet so that the user can put the search bar where she wants), but this simply does not work with UISearchController
    // (the dimming view assumes that the search bar is located as header of the table view). And also forget about having
    // the search bar as footer view :-). Therefore, searchBar has been made read-only
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Track when view has been loaded for the first time (or after an unload)
    m_firstLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Done in viewWillAppear; in viewDidLoad, we would not have had a chance to reach the subclass viewDidLoad code (which
    // e.g. defines the scope buttons if any)
    if (m_firstLoad) {
        // Restore the previous search status (if the view has been unloaded)
        self.searchController.active = m_searchInterfaceActive;
        self.searchBar.text = self.searchText;
        self.searchBar.selectedScopeButtonIndex = m_selectedScopeButtonIndex;
        
        // Simulate a search to reload the data
        if ([self searchDisplayController:self.searchController shouldReloadTableForSearchString:self.searchText]) {
            [self.searchController.searchResultsTableView reloadData];
        }
        
        m_firstLoad = NO;
    }
}

#pragma mark UISearchDisplayDelegate protocol implementation

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerWillBeginSearch:)]) {
        [self.searchDelegate tableSearchDisplayViewControllerWillBeginSearch:self];
    }    
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    m_searchInterfaceActive = YES;
    
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerDidBeginSearch:)]) {
        [self.searchDelegate tableSearchDisplayViewControllerDidBeginSearch:self];
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerWillEndSearch:)]) {
        [self.searchDelegate tableSearchDisplayViewControllerWillEndSearch:self];
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    m_searchInterfaceActive = NO;
    
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerDidEndSearch:)]) {
        [self.searchDelegate tableSearchDisplayViewControllerDidEndSearch:self];
    }    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.searchText = searchString;
    
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewController:shouldReloadTableForSearchString:)]) {
        return [self.searchDelegate tableSearchDisplayViewController:self shouldReloadTableForSearchString:searchString];
    }
    else {
        return YES;
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    m_selectedScopeButtonIndex = searchOption;
    
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewController:shouldReloadTableForSearchScope:)]) {
        return [self.searchDelegate tableSearchDisplayViewController:self shouldReloadTableForSearchScope:searchOption];
    }
    else {
        return YES;
    }
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    MISSING_METHOD_IMPLEMENTATION();
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MISSING_METHOD_IMPLEMENTATION();
    return nil;
}

@end
