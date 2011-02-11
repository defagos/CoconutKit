//
//  TableViewCellsDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TableViewCellsDemoViewController.h"

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
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
                    HLSStandardTableViewCell *cell = HLS_TABLE_VIEW_CELL(HLSStandardTableViewCell, tableView);
                    cell.textLabel.text = @"HLSStandardTableViewCell";
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
                    cell.textLabel.text = NSLocalizedString(@"Custom cell created programmatically", @"Custom cell created programmatically");
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

#if 0
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case CellCategoryIndexSimple: {
            
            break;
        }
            
        case CellCategoryIndexCustom: {
            
            break;
        }
            
        default: {
            
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case CellCategoryIndexSimple: {
            
            break;
        }
            
        case CellCategoryIndexCustom: {
            
            break;
        }
            
        default: {
        
            break;
        }
    }
}
#endif

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CellCategoryIndexSimple: {
            switch (indexPath.row) {
                case SimpleCellIndexDefault: {
                    return HLS_TABLE_VIEW_CELL_HEIGHT(HLSStandardTableViewCell);
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
