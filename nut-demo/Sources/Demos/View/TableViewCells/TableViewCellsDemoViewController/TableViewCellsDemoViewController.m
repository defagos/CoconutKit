//
//  TableViewCellsDemoViewController.m
//  nut-demo
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
    if (self = [super init]) {
        self.title = NSLocalizedString(@"Table view cells", @"Table view cells");
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = HLS_XIB_VIEW_HEIGHT(HeaderView);
    self.tableView.sectionFooterHeight = HLS_XIB_VIEW_HEIGHT(FooterView);
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
                    HLSTableViewCell *cell = HLS_TABLE_VIEW_CELL(HLSTableViewCell, tableView);
                    cell.textLabel.text = @"HLSTableViewCell";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                    
                case SimpleCellIndexValue1: {
                    HLSValue1TableViewCell *cell = HLS_TABLE_VIEW_CELL(HLSValue1TableViewCell, tableView);
                    cell.textLabel.text = @"HLSValue1TableViewCell";
                    cell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                    
                case SimpleCellIndexValue2: {
                    HLSValue2TableViewCell *cell = HLS_TABLE_VIEW_CELL(HLSValue2TableViewCell, tableView);
                    cell.textLabel.text = @"HLSValue2TableViewCell";
                    cell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    HLSSubtitleTableViewCell *cell = HLS_TABLE_VIEW_CELL(HLSSubtitleTableViewCell, tableView);
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
                    XibTableViewCell *cell = HLS_TABLE_VIEW_CELL(XibTableViewCell, tableView);
                    cell.label.text = NSLocalizedString(@"Custom cell from xib", @"Custom cell from xib");
                    cell.imageView.image = [UIImage imageNamed:@"icn_bookmark.png"];
                    // Selection enabled to show that customization works
                    return cell;
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    ProgrammaticTableViewCell *cell = HLS_TABLE_VIEW_CELL(ProgrammaticTableViewCell, tableView);
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
    HeaderView *headerView = HLS_XIB_VIEW(HeaderView);
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
    FooterView *footerView = HLS_XIB_VIEW(FooterView);
    footerView.label.text = NSLocalizedString(@"Section end", @"Section end");
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CellCategoryIndexSimple: {
            switch (indexPath.row) {
                case SimpleCellIndexDefault: {
                    return HLS_TABLE_VIEW_CELL_HEIGHT(HLSTableViewCell);
                    break;
                }
                    
                case SimpleCellIndexValue1: {
                    return HLS_TABLE_VIEW_CELL_HEIGHT(HLSValue1TableViewCell);
                    break;
                }
                    
                case SimpleCellIndexValue2: {
                    return HLS_TABLE_VIEW_CELL_HEIGHT(HLSValue2TableViewCell);
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    return HLS_TABLE_VIEW_CELL_HEIGHT(HLSSubtitleTableViewCell);
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
                    return HLS_TABLE_VIEW_CELL_HEIGHT(XibTableViewCell);
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    return HLS_TABLE_VIEW_CELL_HEIGHT(ProgrammaticTableViewCell);
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
