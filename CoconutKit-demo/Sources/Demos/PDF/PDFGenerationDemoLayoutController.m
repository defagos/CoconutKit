//
//  PDFGenerationDemoLayoutController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PDFGenerationDemoLayoutController.h"

#import "PDFGenerationDemoLayoutFooterView.h"
#import "PDFGenerationDemoLayoutHeaderView.h"
#import "PDFGenerationDemoLayoutTableViewCell.h"

@implementation PDFGenerationDemoLayoutController

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.tableView = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize tableView = m_tableView;

#pragma mark Layout lifecycle

- (void)layoutDidLoad
{
    [super layoutDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.rowHeight = [PDFGenerationDemoLayoutTableViewCell height];
    self.tableView.sectionHeaderHeight = [PDFGenerationDemoLayoutHeaderView height];
    self.tableView.sectionFooterHeight = [PDFGenerationDemoLayoutFooterView height];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    PDFGenerationDemoLayoutTableViewCell *cell = [PDFGenerationDemoLayoutTableViewCell cellForTableView:tableView];
    cell.indexLabel.text = [NSString stringWithFormat:@"%d:%d", indexPath.section, indexPath.row];
    cell.backgroundColor = indexPath.row % 2 ? [UIColor orangeColor] : [UIColor yellowColor];
    return cell;
}

#pragma mark UITableViewDelegate protocol implementation

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // TODO: localize
    PDFGenerationDemoLayoutHeaderView *headerView = [PDFGenerationDemoLayoutHeaderView view];
    headerView.titleLabel.text = [NSString stringWithFormat:@"Header for section %d", section];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // TODO: localize
    PDFGenerationDemoLayoutHeaderView *footerView = [PDFGenerationDemoLayoutFooterView view];
    footerView.titleLabel.text = [NSString stringWithFormat:@"Footer for section %d", section];
    return footerView;    
}

@end
