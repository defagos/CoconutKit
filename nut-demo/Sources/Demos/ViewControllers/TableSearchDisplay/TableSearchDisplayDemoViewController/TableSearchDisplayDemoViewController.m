//
//  TableSearchDisplayDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TableSearchDisplayDemoViewController.h"

#import "DeviceFeedFilter.h"
#import "DeviceInfo.h"
#import "FixedSizeViewController.h"
#import "ModalWrapperViewController.h"

static NSArray *s_data;

typedef enum {
    ScopeButtonIndexEnumBegin = 0,
    ScopeButtonIndexAll = ScopeButtonIndexEnumBegin,
    ScopeButtonIndexMusicPlayers,
    ScopeButtonIndexPhones,
    ScopeButtonIndexTablets,
    ScopeButtonIndexEnumEnd,
    ScopeButtonIndexEnumSize = ScopeButtonIndexEnumEnd - ScopeButtonIndexEnumBegin
} ScopeButtonIndex;

@interface TableSearchDisplayDemoViewController ()

@property (nonatomic, retain) HLSFeed *deviceFeed;
@property (nonatomic, retain) HLSFeedFilter *deviceFeedFilter;
@property (nonatomic, assign) TableSearchDisplayDemoViewController *parentNonModalViewController;       // weak ref

- (DeviceFeedFilter *)buildDeviceFeedFilter;

- (void)modalBarButtonItemClicked:(id)sender;
- (void)closeBarButtonItemClicked:(id)sender;

@end

@implementation TableSearchDisplayDemoViewController

#pragma mark Class methods

+ (void)initialize
{
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Apple iPod" type:DeviceTypeMusicPlayer]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Apple iPod Touch" type:DeviceTypeMusicPlayer]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Apple iPod Nano" type:DeviceTypeMusicPlayer]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Sony Walkman" type:DeviceTypeMusicPlayer]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Apple iPhone 3G" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Apple iPhone 3GS" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Apple iPhone 4" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"HTC Desire" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Nokia 5800 XpressMusic" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"BlackBerry Pearl" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"LG Cookie (KP500)" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Nokia 5310 XpressMusic" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung SGH-D500" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung E250" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung SGH-E700" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung J700" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung S5230" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung T-100" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"LG Shine" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Nokia N95" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung Galaxy S" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung F480 TouchWiz" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Motorola MING A1200i" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"N-Gage" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung SGH-D900" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Sony Ericsson W300" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung S8500" type:DeviceTypePhone]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"HTC Touch" type:DeviceTypePhone]];    
    [data addObject:[DeviceInfo deviceInfoWithName:@"Apple iPad" type:DeviceTypeTablet]];
    [data addObject:[DeviceInfo deviceInfoWithName:@"Samsung Galaxy Tab" type:DeviceTypeTablet]];
    
    s_data = [[NSArray arrayWithArray:data] retain];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = @"HLSTableSearchDisplayViewController";
        self.searchDelegate = self;
        
        self.deviceFeed = [[[HLSFeed alloc] init] autorelease];
        self.deviceFeed.entries = s_data;
    }
    return self;
}

- (void)dealloc
{
    self.deviceFeed = nil;
    self.deviceFeedFilter = nil;
    self.parentNonModalViewController = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize deviceFeed = m_deviceFeed;

@synthesize deviceFeedFilter = m_deviceFeedFilter;

@synthesize parentNonModalViewController = m_parentNonModalViewController;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Can further customize the search bar (color, scope buttons, etc. from viewDidLoad on)
    self.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:NSLocalizedString(@"All", @"All"),
                                        NSLocalizedString(@"Music players", @"Music players"),
                                        NSLocalizedString(@"Phones", @"Phones"),
                                        NSLocalizedString(@"Tablets", @"Tablets"),
                                        nil];
    
    // Trick to show the behavior when added to a navigation controller or when shown normally. In a navigation controller,
    // show a modal button to open the view controller modally
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Modal", @"Modal")
                                                                                   style:UIBarButtonItemStyleBordered 
                                                                                  target:self 
                                                                                  action:@selector(modalBarButtonItemClicked:)]
                                                  autorelease];        
    }
    // Else display a close button
    else {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close")
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(closeBarButtonItemClicked:)]
                                                 autorelease];
    }
    
    // No [tableView reloadData] needed here, the search display controller does it for us
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark HLSTableSearchDisplayViewControllerDelegate protocol implementatio

- (void)tableSearchDisplayViewControllerWillBeginSearch:(HLSTableSearchDisplayViewController *)controller
{
    // We want a search to always open with the "All" scope button selected
    self.searchBar.selectedScopeButtonIndex = ScopeButtonIndexAll;
    
    // Create the corresponding filter
    self.deviceFeedFilter = [self buildDeviceFeedFilter];
}

- (void)tableSearchDisplayViewControllerWillEndSearch:(HLSTableSearchDisplayViewController *)controller;
{
    // No search criteria anymore
    self.deviceFeedFilter = nil;
}

- (BOOL)tableSearchDisplayViewController:(HLSTableSearchDisplayViewController *)controller 
        shouldReloadTableForSearchString:(NSString *)searchString
{
    // Create the corresponding filter
    self.deviceFeedFilter = [self buildDeviceFeedFilter];
    
    // Trigger a search result table view reload
    return YES;
}

- (BOOL)tableSearchDisplayViewController:(HLSTableSearchDisplayViewController *)controller 
         shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Clear the filter
    self.deviceFeedFilter = [self buildDeviceFeedFilter];
    
    // Trigger a search result table view reload
    return YES;
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deviceFeed countMatchingFilter:self.deviceFeedFilter];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{   
    DeviceInfo *deviceInfo = [self.deviceFeed entryAtIndex:indexPath.row matchingFilter:self.deviceFeedFilter];
    HLSTableViewCell *cell = HLS_TABLE_VIEW_CELL(HLSTableViewCell, tableView);
    cell.textLabel.text = deviceInfo.name;
    
    // In navigation controller: Can test behavior when another level is pushed
    if (self.navigationController) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // Modal: In this example, we have no navigation controller available. Cannot navigate further
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Push another dummy level
    if (self.navigationController) {
        FixedSizeViewController *fixedSizeViewController = [[[FixedSizeViewController alloc] init] autorelease];
        [self.navigationController pushViewController:fixedSizeViewController animated:YES];        
    }
}

#pragma mark Creating the search filter

- (DeviceFeedFilter *)buildDeviceFeedFilter
{
    DeviceFeedFilter *filter = [[[DeviceFeedFilter alloc] initWithFeed:self.deviceFeed] autorelease];
    filter.pattern = self.searchBar.text;
    
    switch (self.searchBar.selectedScopeButtonIndex) {            
        case ScopeButtonIndexMusicPlayers: {
            filter.type = DeviceTypeMusicPlayer;
            break;
        }
            
        case ScopeButtonIndexPhones: {
            filter.type = DeviceTypePhone;            
            break;
        }
            
        case ScopeButtonIndexTablets: {
            filter.type = DeviceTypeTablet;
            break;
        }
            
        case ScopeButtonIndexAll:
        default: {
            filter.type = DeviceTypeAll;
            break;
        }
    }
        
    return filter;
}

#pragma mark Event callbacks

- (void)modalBarButtonItemClicked:(id)sender
{
    // Create the modal version; keep a weak ref to the view controller (self) which presents the modal
    TableSearchDisplayDemoViewController *demoViewController = [[[TableSearchDisplayDemoViewController alloc] init] autorelease];
    demoViewController.parentNonModalViewController = self;
    
    // Wrapped for providing navigation bar even in modal version
    ModalWrapperViewController *modalWrapperViewController = [[[ModalWrapperViewController alloc] init] autorelease];
    modalWrapperViewController.insetViewController = demoViewController;
    modalWrapperViewController.adjustingInset = YES;
    
    [self presentModalViewController:modalWrapperViewController animated:YES];
}

- (void)closeBarButtonItemClicked:(id)sender
{
    // Modal version requests close; ask view controller responsible for modal display to dismiss the view controller
    [self.parentNonModalViewController dismissModalViewControllerAnimated:YES];
    self.parentNonModalViewController = nil;
}

@end
