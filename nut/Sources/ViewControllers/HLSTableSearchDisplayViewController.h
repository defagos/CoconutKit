//
//  HLSTableSearchDisplayViewController.h
//  nut
//
//  Created by Samuel Défago on 8/23/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewController.h"

// Forward declarations
@class HLSTableSearchDisplayViewController;

@protocol HLSTableSearchDisplayViewControllerDelegate <NSObject>

@optional
// Called when we start/end showing the search UI (use willBeginSearch to initialize the search string with some meaningful value if
// you want)
- (void)tableSearchDisplayViewControllerWillBeginSearch:(HLSTableSearchDisplayViewController *)controller;
- (void)tableSearchDisplayViewControllerDidBeginSearch:(HLSTableSearchDisplayViewController *)controller;
- (void)tableSearchDisplayViewControllerWillEndSearch:(HLSTableSearchDisplayViewController *)controller;
- (void)tableSearchDisplayViewControllerDidEndSearch:(HLSTableSearchDisplayViewController *)controller;

// Return YES to reload table. Called when search string/option changes. Convenience methods on top UISearchBar delegate methods
- (BOOL)tableSearchDisplayViewController:(HLSTableSearchDisplayViewController *)controller 
        shouldReloadTableForSearchString:(NSString *)searchString;
- (BOOL)tableSearchDisplayViewController:(HLSTableSearchDisplayViewController *)controller 
         shouldReloadTableForSearchScope:(NSInteger)searchOption;

@end

typedef enum {
    HLSTableSearchStyleBuiltIn = 0,
    HLSTableSearchStyleTrueScopeButtons
} HLSTableSearchStyle;

/**
 * This class mimics the UISearchDisplayController class, but with the difference that the scope bar buttons can
 * be used even if no search string is entered. It manages two table views:
 *   - one table view displaying all entries when the search interface is inactive (tableView)
 *   - one table view displaying only matching engtries when the search interface is active (searchResultsTableView)
 * To implement your own table views with search interface, inherit from HLSTableSearchDisplayViewController. When
 * implementating the UITableViewDataSource mandatory protocol methods, you can use the two table view accessors
 * to find which table view a method is called for (if needed).
 *
 * Moreover, the use of this class is limited to filtering entries managed by a UITableView. This is namely by far the 
 * most common use of UISearchDisplayController. This also allows us to reuse the original table view to display the 
 * results (the added flexibility that UISearchDisplayController provides is not really worth the price).
 *
 * To provide the user with the ability to customize the view controller layout, this class does not inherit directly from
 * UITableViewController, but from UIViewController. Classes derived from this class are therefore expected to initialize
 * the table view outlet provided, either using Interface Builder or programmatically.
 *
 * As for UITableViewController, this class conforms to the table view protocols for convenience, but does not provide
 * any meaningful implementations for them. Subclasses are required to override at least the required UITableViewDataSource
 * protocol methods displaying records (tableView:numberOfRowsInSection: and tableView:cellForRowAtIndexPath:).
 *
 * You never need to reload the table view of a HLSTableSearchDisplayViewController directly. Instead, implement the
 *              tableSearchDisplayViewController:shouldReloadTableForSearchString:
 *      and     tableSearchDisplayViewController:shouldReloadTableForSearchScope:
 * delegate methods to return YES when the table view needs reloading.
 *
 * Remark: If you override viewDidLoad, viewWillAppear, etc., do not forget to call their super counterpart (as usual),
 *         otherwise the behavior is undefined.
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSTableSearchDisplayViewController : HLSViewController <
    UISearchBarDelegate, 
    UISearchDisplayDelegate,
    UITableViewDataSource,
    UITableViewDelegate
> {
@private
    UISearchBar *m_searchBar;
    UITableView *m_tableView;
    HLSTableSearchStyle m_style;
    UISearchDisplayController *m_searchController;
    BOOL m_scopeButtonHookInstalled;
    id<HLSTableSearchDisplayViewControllerDelegate> m_searchDelegate;
}

/**
 * The search bar is created and managed for you, but you can use this accessor for customizing it if needed. This search bar is available
 * once the view has been loaded (viewDidLoad and later in the view lifecycle)
 */
@property (nonatomic, readonly, retain) UISearchBar *searchBar;

/**
 * Derived classes must initialize this outlet, either using Interface Builder or programmatically (i.e. when implementing the loadView method).
 * You never need (and therefore should) call reloadData on this table view manually, the HLSTableSearchDisplayViewController view controller
 * will do it for you. This is the table view which displays the entries when the search interface is inactive.
 */
@property (nonatomic, retain) IBOutlet UITableView *tableView;

/**
 * The table view displaying the entries matching a search criterium
 */
@property (nonatomic, readonly, assign) UITableView *searchResultsTableView;

/**
 * The search style to apply. Default is HLSTableSearchStyleBuiltIn
 */
@property (nonatomic, assign) HLSTableSearchStyle style;

/**
 * Delegate receiving search interface events
 */
@property (nonatomic, assign) id<HLSTableSearchDisplayViewControllerDelegate> searchDelegate;

@end
