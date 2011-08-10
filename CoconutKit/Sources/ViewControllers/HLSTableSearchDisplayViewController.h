//
//  HLSTableSearchDisplayViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewController.h"

/**
 * This class conveniently implements the UISearchDisplayController behavior for a table view (the most common case). It 
 * manages two table views:
 *   - one table view displaying all entries when the search interface is inactive (tableView)
 *   - one table view displaying only matching entries when the search interface is active (searchResultsTableView)
 * To create your own table view with search interface, subclass HLSTableSearchDisplayViewController and override 
 * the UISearchDisplayDelegate delegate methods to suit your needs.
 *
 * To provide the user with the ability to customize the view controller layout, this class does not inherit directly from
 * UITableViewController, but from HLSViewController. Classes derived from this class are therefore expected to initialize
 * the table view outlet provided, either using Interface Builder or programmatically.
 *
 * As for UITableViewController, this class conforms to the table view protocols for convenience, but does not provide
 * any meaningful implementations for them. Subclasses are required to override at least the required UITableViewDataSource
 * protocol methods displaying records (tableView:numberOfRowsInSection: and tableView:cellForRowAtIndexPath:). When
 * implementing these methods, you can use the tableView and searchResultsTableView accessors to identify which table
 * view is querying the data source. This allows you to use the proper record set.s
 *
 * You never need to reload the table views of a HLSTableSearchDisplayViewController directly. Instead, implement the
 *              searchDisplayController:shouldReloadTableForSearchString:
 *      and     searchDisplayController:shouldReloadTableForSearchScope:
 * UISearchDisplayDelegate methods to return YES when the table view needs reloading. These methods are called each 
 * time the search string or the search scope are changed.
 *
 * HLSTableSearchDisplayViewController saves the current search criteria and restore them if the view has been
 * unloaded. You do not have to code this mechanism yourself.
 *
 * This class only implements the standard UISearchDisplayController behavior (scope buttons are only active when a
 * search string has been entered). Having scope buttons active even if no search criterium is entered requires
 * further investigation (it would be nice to implement this behavior using UISearchDisplayController. Otherwise
 * we must code everything from scratch, with tricky animations requiring access to private implementation details,
 * layouts different for portrait and landscape orientations, etc. Not an easy task.
 *
 * Remark: If you override viewDidLoad, viewWillAppear, etc., do not forget to call their super counterpart (as usual),
 *         otherwise the behavior is undefined. The same holds for the UISearchDisplayDelegate methods
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSTableSearchDisplayViewController : HLSViewController <
    UISearchDisplayDelegate,
    UITableViewDataSource,
    UITableViewDelegate
> {
@private
    UISearchBar *m_searchBar;
    UITableView *m_tableView;
    NSString *m_searchText;
    NSInteger m_selectedScopeButtonIndex;
    BOOL m_searchInterfaceActive;
    UISearchDisplayController *m_searchController;
    BOOL m_firstLoad;
}

/**
 * The search bar is created and managed for you, but you can use this accessor for customizing it if needed. This search bar is available
 * once the view has been loaded (viewDidLoad or later in the view lifecycle)
 */
@property (nonatomic, readonly, retain) UISearchBar *searchBar;

/**
 * The table view displaying all entries when the search interface is inactive
 *
 * Derived classes must initialize this outlet, either using Interface Builder or programmatically (i.e. when implementing the loadView method).
 * You never need to (and therefore should) call reloadData on this table view manually, the HLSTableSearchDisplayViewController view controller
 * will take care of this for you.
 */
@property (nonatomic, retain) IBOutlet UITableView *tableView;

/**
 * The table view displaying the entries matching a search criterium
 */
@property (nonatomic, readonly, assign) UITableView *searchResultsTableView;

@end
