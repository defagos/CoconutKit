//
//  PDFGenerationDemoLayoutController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PDFGenerationDemoLayoutController.h"

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
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#if 0

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
}

#endif

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    PDFGenerationDemoLayoutTableViewCell *cell = [PDFGenerationDemoLayoutTableViewCell cellForTableView:tableView];
    cell.indexLabel.text = [NSString stringWithFormat:@"%d:%d", indexPath.section, indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate protocol implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PDFGenerationDemoLayoutTableViewCell height];
}

#if 0

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
}

#endif

@end
