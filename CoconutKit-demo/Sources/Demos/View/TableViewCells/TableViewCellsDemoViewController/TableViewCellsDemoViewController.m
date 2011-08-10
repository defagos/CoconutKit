//
//  TableViewCellsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TableViewCellsDemoViewController.h"

#import "FooterView.h"
#import "HeaderView.h"
#import "ProgrammaticTableViewCell.h"
#import "XibTableViewCell.h"

// Categories
typedef enum {
    CellCategoryIndexEnumBegin = 0,
    CellCategoryIndexSimple = CellCategoryIndexEnumBegin,
    CellCategoryIndexCustom,
    CellCategoryIndexEnumEnd,
    CellCategoryIndexEnumSize = CellCategoryIndexEnumEnd - CellCategoryIndexEnumBegin
} CellCategoryIndex;

// Simple cells
typedef enum {
    SimpleCellIndexEnumBegin = 0,
    SimpleCellIndexDefault = SimpleCellIndexEnumBegin,
    SimpleCellIndexValue1,
    SimpleCellIndexValue2,
    SimpleCellIndexSubtitle,
    SimpleCellIndexEnumEnd,
    SimpleCellIndexEnumSize = SimpleCellIndexEnumEnd - SimpleCellIndexEnumBegin
} SimpleCellIndex;

// Custom cells
typedef enum {
    CustomCellIndexEnumBegin = 0,
    CustomCellIndexXib = CustomCellIndexEnumBegin,
    CustomCellIndexProgrammatically,
    CustomCellIndexEnumEnd,
    CustomCellIndexEnumSize = CustomCellIndexEnumEnd - CustomCellIndexEnumBegin
} CustomCellIndex;

@implementation TableViewCellsDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Table view cells", @"Table view cells");
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = HLSXibViewHeight(HeaderView);
    self.tableView.sectionFooterHeight = HLSXibViewHeight(FooterView);
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return CellCategoryIndexEnumSize;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case CellCategoryIndexSimple: {
            return SimpleCellIndexEnumSize;
            break;
        }
            
        case CellCategoryIndexCustom: {
            return CustomCellIndexEnumSize;
            break;
        }
            
        default: {
            return 0;
            break;
        }
    }   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    switch (indexPath.section) {
        case CellCategoryIndexSimple: {
            switch (indexPath.row) {
                case SimpleCellIndexDefault: {
                    HLSTableViewCell *cell = HLSTableViewCellGet(HLSTableViewCell, tableView);
                    cell.textLabel.text = @"HLSTableViewCell";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                    
                case SimpleCellIndexValue1: {
                    HLSValue1TableViewCell *cell = HLSTableViewCellGet(HLSValue1TableViewCell, tableView);
                    cell.textLabel.text = @"HLSValue1TableViewCell";
                    cell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                    
                case SimpleCellIndexValue2: {
                    HLSValue2TableViewCell *cell = HLSTableViewCellGet(HLSValue2TableViewCell, tableView);
                    cell.textLabel.text = @"HLSValue2TableViewCell";
                    cell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    HLSSubtitleTableViewCell *cell = HLSTableViewCellGet(HLSSubtitleTableViewCell, tableView);
                    cell.textLabel.text = @"HLSSubtitleTableViewCell";
                    cell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;                    
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        case CellCategoryIndexCustom: {
            switch (indexPath.row) {
                case CustomCellIndexXib: {
                    XibTableViewCell *cell = HLSTableViewCellGet(XibTableViewCell, tableView);
                    cell.label.text = NSLocalizedString(@"Custom cell from xib", @"Custom cell from xib");
                    cell.imageView.image = [UIImage imageNamed:@"icn_bookmark.png"];
                    // Selection enabled to show that customization works
                    return cell;
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    ProgrammaticTableViewCell *cell = HLSTableViewCellGet(ProgrammaticTableViewCell, tableView);
                    cell.label.text = NSLocalizedString(@"Custom cell created programmatically", @"Custom cell created programmatically");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        default: {
            return nil;
            break;
        }            
    }
}

#pragma mark UITableViewDelegate protocol implementation

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeaderView *headerView = HLSXibViewGet(HeaderView);
    switch (section) {
        case CellCategoryIndexSimple: {
            headerView.label.text = NSLocalizedString(@"Header: simple cells", @"Header: simple cells");
            break;
        }
            
        case CellCategoryIndexCustom: {
            headerView.label.text = NSLocalizedString(@"Header: custom cells", @"Header: custom cells");            
            break;
        }
            
        default: {
            return nil;
            break;
        }
    }
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    FooterView *footerView = HLSXibViewGet(FooterView);
    footerView.label.text = NSLocalizedString(@"Section end", @"Section end");
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CellCategoryIndexSimple: {
            switch (indexPath.row) {
                case SimpleCellIndexDefault: {
                    return HLSTableViewCellHeight(HLSTableViewCell);
                    break;
                }
                    
                case SimpleCellIndexValue1: {
                    return HLSTableViewCellHeight(HLSValue1TableViewCell);
                    break;
                }
                    
                case SimpleCellIndexValue2: {
                    return HLSTableViewCellHeight(HLSValue2TableViewCell);
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    return HLSTableViewCellHeight(HLSSubtitleTableViewCell);
                    break;
                }
                    
                default: {
                    return 0;
                    break;
                }            
            }            
        }
            
        case CellCategoryIndexCustom: {
            switch (indexPath.row) {
                case CustomCellIndexXib: {
                    return HLSTableViewCellHeight(XibTableViewCell);
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    return HLSTableViewCellHeight(ProgrammaticTableViewCell);
                    break;
                }
                    
                default: {
                    return 0;
                    break;
                }            
            }
            break;
        }
            
        default: {
            return 0;
            break;
        }            
    }     
}

@end
