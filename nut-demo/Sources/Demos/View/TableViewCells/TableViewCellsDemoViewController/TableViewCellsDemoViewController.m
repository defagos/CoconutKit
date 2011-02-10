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
                    HLSStandardTableViewCell *cell = SIMPLE_TABLE_VIEW_CELL_PROGRAMMATICALLY(UITableViewCellStyleDefault, tableView);
                    cell.textLabel.text = NSLocalizedString(@"Simple cell, default style", @"Simple cell, default style");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    HLSStandardTableViewCell *cell = SIMPLE_TABLE_VIEW_CELL_PROGRAMMATICALLY(UITableViewCellStyleSubtitle, tableView);
                    cell.textLabel.text = NSLocalizedString(@"Simple cell, subtitle", @"Simple cell, subtitle");
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
                    XibTableViewCell *cell = CUSTOM_TABLE_VIEW_CELL_FROM_XIB(XibTableViewCell, tableView);
                    cell.label.text = NSLocalizedString(@"Custom cell from xib", @"Custom cell from xib");
                    cell.imageView.image = [UIImage imageNamed:@"icn_bookmark.png"];
                    // Selection enabled to show that customization works
                    return cell;
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    ProgrammaticTableViewCell *cell = CUSTOM_TABLE_VIEW_CELL_PROGRAMMATICALLY(ProgrammaticTableViewCell, tableView);
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
            return SIMPLE_TABLE_VIEW_CELL_HEIGHT();
        }
            
        case CellCategoryIndexCustom: {
            switch (indexPath.row) {
                case CustomCellIndexXib: {
                    return CUSTOM_TABLE_VIEW_CELL_HEIGHT(XibTableViewCell);
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    return CUSTOM_TABLE_VIEW_CELL_HEIGHT(ProgrammaticTableViewCell);
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
