//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "TableSearchDisplayDemoViewController.h"

#import "DeviceInfo.h"
#import "StretchableViewController.h"

typedef NS_ENUM(NSInteger, ScopeButtonIndex) {
    ScopeButtonIndexEnumBegin = 0,
    ScopeButtonIndexAll = ScopeButtonIndexEnumBegin,
    ScopeButtonIndexMusicPlayers,
    ScopeButtonIndexPhones,
    ScopeButtonIndexTablets,
    ScopeButtonIndexEnumEnd,
    ScopeButtonIndexEnumSize = ScopeButtonIndexEnumEnd - ScopeButtonIndexEnumBegin
} ;

@interface TableSearchDisplayDemoViewController ()

@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, strong) NSArray *filteredDevices;

@end

@implementation TableSearchDisplayDemoViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        NSMutableArray *devices = [NSMutableArray array];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Apple iPod" type:DeviceTypeMusicPlayer]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Apple iPod Touch" type:DeviceTypeMusicPlayer]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Apple iPod Nano" type:DeviceTypeMusicPlayer]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Sony Walkman" type:DeviceTypeMusicPlayer]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Apple iPhone 3G" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Apple iPhone 3GS" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Apple iPhone 4" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"HTC Desire" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Nokia 5800 XpressMusic" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"BlackBerry Pearl" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"LG Cookie (KP500)" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Nokia 5310 XpressMusic" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung SGH-D500" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung E250" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung SGH-E700" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung J700" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung S5230" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung T-100" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"LG Shine" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Nokia N95" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung Galaxy S" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung F480 TouchWiz" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Motorola MING A1200i" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"N-Gage" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung SGH-D900" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Sony Ericsson W300" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung S8500" type:DeviceTypePhone]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"HTC Touch" type:DeviceTypePhone]];    
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Apple iPad" type:DeviceTypeTablet]];
        [devices addObject:[DeviceInfo deviceInfoWithName:@"Samsung Galaxy Tab" type:DeviceTypeTablet]];
        
        self.devices = [NSArray arrayWithArray:devices];
    }
    return self;
}

#pragma mark UISearchDisplayDelegate protocol implementation

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [super searchDisplayControllerWillBeginSearch:controller];
    
    // We want a search to always open with the "All" scope button selected
    self.searchBar.selectedScopeButtonIndex = ScopeButtonIndexAll;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [super searchDisplayController:controller shouldReloadTableForSearchString:searchString];
    
    // Refresh the results
    [self filterDevices];
    
    // Trigger a search result table view reload
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [super searchDisplayController:controller shouldReloadTableForSearchScope:searchOption];
    
    // Refresh the results
    [self filterDevices];
    
    // Trigger a search result table view reload
    return YES;
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchResultsTableView) {
        return [self.filteredDevices count];
    }
    else {
        return [self.devices count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{   
    DeviceInfo *device = nil;
    if (tableView == self.searchResultsTableView) {
        device = [self.filteredDevices objectAtIndex:indexPath.row];
    }
    else {
        device = [self.devices objectAtIndex:indexPath.row];
    }
    
    HLSTableViewCell *cell = [HLSTableViewCell cellForTableView:tableView];
    cell.textLabel.text = device.name;
    
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
        StretchableViewController *stretchableViewController = [[StretchableViewController alloc] init];
        [self.navigationController pushViewController:stretchableViewController animated:YES];        
    }
}

#pragma mark Creating the search filter

- (void)filterDevices
{
    DeviceType deviceType;
    switch (self.searchBar.selectedScopeButtonIndex) {            
        case ScopeButtonIndexMusicPlayers: {
            deviceType = DeviceTypeMusicPlayer;
            break;
        }
            
        case ScopeButtonIndexPhones: {
            deviceType = DeviceTypePhone;            
            break;
        }
            
        case ScopeButtonIndexTablets: {
            deviceType = DeviceTypeTablet;
            break;
        }
            
        case ScopeButtonIndexAll:
        default: {
            deviceType = DeviceTypeAll;
            break;
        }
    }
    
    NSString *pattern = self.searchBar.text;
    NSMutableArray *filteredDevices = [NSMutableArray array];
    for (DeviceInfo *device in self.devices) {
        // Try to locate the pattern in the name (if any)
        if ([pattern length] != 0) {
            NSRange prefixRange = [device.name rangeOfString:pattern
                                                     options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
            if (prefixRange.length == 0) {
                continue;
            }        
        }
        
        // Check against device type (if any)
        if (deviceType != DeviceTypeAll && device.type != deviceType) {
            continue;
        }
        
        // All checks successful; matches the filter criteria
        [filteredDevices addObject:device];
    }
    
    self.filteredDevices = [NSArray arrayWithArray:filteredDevices];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HLSTableSearchDisplayViewController";
    self.searchBar.scopeButtonTitles = @[NSLocalizedString(@"All", nil),
                                         NSLocalizedString(@"Music players", nil),
                                         NSLocalizedString(@"Phones", nil),
                                         NSLocalizedString(@"Tablets", nil)];
}

@end
