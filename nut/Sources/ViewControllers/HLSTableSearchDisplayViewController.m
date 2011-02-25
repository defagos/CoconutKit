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
@property (nonatomic, retain) UISearchDisplayController *searchController;      // Not called searchDisplayController to avoid conflicts with 
                                                                                // UIViewController's searchViewController property
@end

@implementation HLSTableSearchDisplayViewController

#pragma mark Object creation and destruction

- (void)dealloc
{
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
    
    // Hool is installed on scope buttons. If the view is newly instantiated, the hook must be installed again
    m_scopeButtonHookInstalled = NO;
}

#pragma mark UISearchDisplayDelegate protocol implementation

// TODO: Attention: Vérifier qu'avec le hook cette méthode n'est pas appelée 2 fois!!

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerWillBeginSearch:)]) {
        [self.searchDelegate tableSearchDisplayViewControllerWillBeginSearch:self];
    }    
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
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
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewControllerDidEndSearch:)]) {
        [self.searchDelegate tableSearchDisplayViewControllerDidEndSearch:self];
    }    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([self.searchDelegate respondsToSelector:@selector(tableSearchDisplayViewController:shouldReloadTableForSearchString:)]) {
        return [self.searchDelegate tableSearchDisplayViewController:self shouldReloadTableForSearchString:searchString];
    }
    else {
        return YES;
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
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
