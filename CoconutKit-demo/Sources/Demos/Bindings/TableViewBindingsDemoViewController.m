//
//  TableViewBindingsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "TableViewBindingsDemoViewController.h"

#import "Employee.h"
#import "EmployeeHeaderView.h"
#import "EmployeeTableViewCell.h"

@interface TableViewBindingsDemoViewController ()

@property (nonatomic, strong) NSArray *employees;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation TableViewBindingsDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        Employee *employee1 = [[Employee alloc] init];
        employee1.fullName = @"Jack Bauer";
        employee1.age = @40;
        
        Employee *employee2 = [[Employee alloc] init];
        employee2.fullName = @"Tony Soprano";
        employee2.age = @46;
        
        Employee *employee3 = [[Employee alloc] init];
        employee3.fullName = @"Walter White";
        employee3.age = @52;
        
        self.employees = @[employee1, employee2, employee3];
    }
    return self;
}

#pragma mark Accessors and mutators

- (NSString *)numberOfEmployeesString
{
    return [NSString stringWithFormat:NSLocalizedString(@"%d employees", nil), [self.employees count]];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = [EmployeeTableViewCell height];
    self.tableView.sectionHeaderHeight = [EmployeeHeaderView height];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Table view", nil);
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.employees count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EmployeeTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmployeeTableViewCell *employeeCell = (EmployeeTableViewCell *)cell;
    employeeCell.employee = [self.employees objectAtIndex:indexPath.row];
    employeeCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [EmployeeHeaderView view];
}

@end
