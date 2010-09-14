//
//  HLSTableSearchDisplayController.h
//  nut
//
//  Created by Samuel Défago on 8/23/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Forward declarations
@class HLSTableSearchDisplayController;

@protocol TableSearchDisplayDelegate <NSObject>

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
 * Moreover, the use of this class is limited to filtering entries managed by a UITableViewController. This is
 * namely by far the most common use of UISearchDisplayController, which does not even support all cases
 * for table views (try e.g. adding the search bar as table view footer, you will see what I mean). This also
 * allows us to reuse the original table view to display the results (the added flexibility that UISearchDisplayController
 * provides is not really worth its price). In contrast to UISearchDisplayController, this class therefore can directly
 * inherit from UITableViewController, and to benefit from it you just need to derive from it instead of from
 * UITableViewController.
 *
 * Table reload is handled in the following way:
 *   - if the class inheriting from HLSTableSearchDisplayController implements the HLSReloadable protocol, the protocol
 *     reloadData method is called when the search criteria are updated. Since the class is ultimately a table view,
 *     the reloadData method must call the UITableView reloadData method, otherwise the behavior is undefined
 *   - if the class inheriting from HLSTableSearchDisplayController does not implement the HLSReloadable protocol, the
 *     UITableView reloadData method is used
 *
 * Remark: If you override viewDidLoad, viewWillAppear, etc., do not forget to call its super counterpart (as usual),
 *         otherwise the HLSTableSearchDisplayController will not work correctly.
 *
 * Designated initializer: initWithStyle:
 */
@interface HLSTableSearchDisplayController : UITableViewController <UISearchBarDelegate, TableSearchDisplayDelegate> {
@private
    UISearchBar *m_searchBar;
    id<TableSearchDisplayDelegate> m_searchDelegate;
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

@property (nonatomic, assign) id<TableSearchDisplayDelegate> searchDelegate;

@end
