//
//  HLSTableSearchDisplayController.h
//  nut
//
//  Created by Samuel Défago on 8/23/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Forward declarations
@class HLSTableSearchDisplayController;

@protocol HLSTableSearchDisplayDelegate <NSObject>

@optional
// when we start/end showing the search UI (use willBeginSearch to initialize the search string with some meaningful value if
// you want)
- (void)tableSearchDisplayControllerWillBeginSearch:(HLSTableSearchDisplayController *)controller;
- (void)tableSearchDisplayControllerDidBeginSearch:(HLSTableSearchDisplayController *)controller;
- (void)tableSearchDisplayControllerWillEndSearch:(HLSTableSearchDisplayController *)controller;
- (void)tableSearchDisplayControllerDidEndSearch:(HLSTableSearchDisplayController *)controller;

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)tableSearchDisplayController:(HLSTableSearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
- (BOOL)tableSearchDisplayController:(HLSTableSearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption;
- (BOOL)tableSearchDisplayControllerShouldReloadOriginalTable:(HLSTableSearchDisplayController *)controller;

@end

/**
 * This class mimics the UISearchDisplayController class, but with the difference that the scope bar buttons can
 * be used even if no search string is entered.
 *
 * Moreover, the use of this class is limited to filtering entries managed by a UITableView. This is
 * namely by far the most common use of UISearchDisplayController, which does not even support all cases
 * for table views (try e.g. adding the search bar as table view footer, you will see what I mean). This also
 * allows us to reuse the original table view to display the results (the added flexibility that UISearchDisplayController
 * provides is not really worth its price).
 *
 * To provide the user with the ability to customize the view controller layout, this class does not inherit directly from
 * UITableViewController, but from UIViewController. Classes derived from this class are therefore expected to initialize
 * the table view outlet provided, either using Interface Builder or via code.
 *
 * Table reload is handled in the following way:
 *   - if the class inheriting from HLSTableSearchDisplayController implements the HLSReloadable protocol, the protocol
 *     reloadData method is called when the search criteria are updated. Since the class is ultimately a table view,
 *     the reloadData method must call the UITableView reloadData method, otherwise the behavior is undefined
 *   - if the class inheriting from HLSTableSearchDisplayController does not implement the HLSReloadable protocol, the
 *     UITableView reloadData method is used
 *
 * As for UITableViewController, this class conforms to the table view protocols for convenience, but does not provide
 * any meaningful implementations for them. Subclasses are required to override at least the required UITableViewDataSource
 * protocol methods to display records.
 *
 * Remark: If you override viewDidLoad, viewWillAppear, etc., do not forget to call its super counterpart (as usual),
 *         otherwise the HLSTableSearchDisplayController will not work correctly.
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSTableSearchDisplayController : UIViewController <
    HLSTableSearchDisplayDelegate,
    UISearchBarDelegate, 
    UITableViewDataSource,
    UITableViewDelegate
> {
@private
    UISearchBar *m_searchBar;
    UITableView *m_tableView;
    id<HLSTableSearchDisplayDelegate> m_searchDelegate;
    BOOL m_firstTime;
    struct {
        unsigned int delegateWillBeginSearch:1;
        unsigned int delegateDidBeginSearch:1;
        unsigned int delegateWillEndSearch:1;
        unsigned int delegateDidEndSearch:1;
        unsigned int delegateShouldReloadTableForSearchString:1;
        unsigned int delegateShouldReloadTableForSearchScope:1;
        unsigned int delegateShouldReloadOriginalTable;
    } m_flags;
}

/**
 * Controls whether the search interface is active
 */
- (void)setActive:(BOOL)visible animated:(BOOL)animated;

/**
 * The search bar is created and managed for you, but you can use this accessor for customizing it if needed
 */
@property (nonatomic, readonly, retain) UISearchBar *searchBar;

/**
 * Derived classes must initialize this outlet, either using Interface Builder or via code (i.e. when implementing the loadView method)
 */
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, assign) id<HLSTableSearchDisplayDelegate> searchDelegate;

@end
