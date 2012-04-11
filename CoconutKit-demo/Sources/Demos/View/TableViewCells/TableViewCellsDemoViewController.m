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

@interface TableViewCellsDemoViewController ()

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation TableViewCellsDemoViewController

@synthesize tableView = m_tableView;

#pragma mark View lifecycle

- (void)loadView
{
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.view = self.tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = [HeaderView height];
    self.tableView.sectionFooterHeight = [FooterView height];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)releaseViews
{
    [super releaseViews];
    self.tableView = nil;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Table view cells", @"Table view cells");
    [self.tableView reloadData];
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
                    return [HLSTableViewCell cellForTableView:tableView];
                    break;
                }
                    
                case SimpleCellIndexValue1: {
                    return [HLSValue1TableViewCell cellForTableView:tableView];
                    break;
                }
                    
                case SimpleCellIndexValue2: {
                    return [HLSValue2TableViewCell cellForTableView:tableView];
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    return [HLSSubtitleTableViewCell cellForTableView:tableView];
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
                    return [XibTableViewCell cellForTableView:tableView];
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    return [ProgrammaticTableViewCell cellForTableView:tableView];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.section) {
        case CellCategoryIndexSimple: {
            switch (indexPath.row) {
                case SimpleCellIndexDefault: {
                    HLSTableViewCell *tableViewCell = (HLSTableViewCell *)cell;
                    tableViewCell.textLabel.text = @"HLSTableViewCell";
                    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                    
                case SimpleCellIndexValue1: {
                    HLSValue1TableViewCell *tableViewCell = (HLSValue1TableViewCell *)cell;
                    tableViewCell.textLabel.text = @"HLSValue1TableViewCell";
                    tableViewCell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                    
                case SimpleCellIndexValue2: {
                    HLSValue2TableViewCell *tableViewCell = (HLSValue2TableViewCell *)cell;
                    tableViewCell.textLabel.text = @"HLSValue2TableViewCell";
                    tableViewCell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    HLSSubtitleTableViewCell *tableViewCell = (HLSSubtitleTableViewCell *)cell;
                    tableViewCell.textLabel.text = @"HLSSubtitleTableViewCell";
                    tableViewCell.detailTextLabel.text = NSLocalizedString(@"Details", @"Details");
                    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;                    
                    break;
                }
                    
                default: {
                    break;
                }            
            }
            break;
        }
            
        case CellCategoryIndexCustom: {
            switch (indexPath.row) {
                case CustomCellIndexXib: {
                    XibTableViewCell *tableViewCell = (XibTableViewCell *)cell;
                    tableViewCell.label.text = NSLocalizedString(@"Custom cell from xib", @"Custom cell from xib");
                    tableViewCell.imageView.image = [UIImage imageNamed:@"icn_bookmark.png"];
                    // Selection here enabled to show that customization works
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    ProgrammaticTableViewCell *tableViewCell = (ProgrammaticTableViewCell *)cell;
                    tableViewCell.label.text = NSLocalizedString(@"Custom cell created programmatically", @"Custom cell created programmatically");
                    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                    
                default: {
                    break;
                }            
            }
            break;
        }
            
        default: {
            break;
        }            
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeaderView *headerView = [HeaderView view];
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
    FooterView *footerView = [FooterView view];
    footerView.label.text = NSLocalizedString(@"Section end", @"Section end");
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CellCategoryIndexSimple: {
            switch (indexPath.row) {
                case SimpleCellIndexDefault: {
                    return [HLSTableViewCell height];
                    break;
                }
                    
                case SimpleCellIndexValue1: {
                    return [HLSValue1TableViewCell height];
                    break;
                }
                    
                case SimpleCellIndexValue2: {
                    return [HLSValue2TableViewCell height];
                    break;
                }
                    
                case SimpleCellIndexSubtitle: {
                    return [HLSSubtitleTableViewCell height];
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
                    return [XibTableViewCell height];
                    break;
                }
                    
                case CustomCellIndexProgrammatically: {
                    return [ProgrammaticTableViewCell height];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Nicer effect when clicking on the only active cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
