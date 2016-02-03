//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsViewsDemoViewController.h"

#import "Employee.h"
#import "EmployeeHeaderView.h"
#import "EmployeeTableViewCell.h"
#import "EmployeeView.h"

@interface BindingsViewsDemoViewController ()

@property (nonatomic, strong) NSArray *employees;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet EmployeeView *employeeView;

@end

@implementation BindingsViewsDemoViewController {
@private
    NSInteger _currentEmployeeIndex;
}

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.employees = [Employee employees];
    }
    return self;
}

#pragma mark Accessors and mutators

- (NSString *)numberOfEmployeesString
{
    return [NSString stringWithFormat:NSLocalizedString(@"%@ employees", nil), @([self.employees count])];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.rowHeight = [EmployeeTableViewCell height];
    self.tableView.sectionHeaderHeight = [EmployeeHeaderView height];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self changeEmployee];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Views", nil);
}

#pragma mark Updating data

- (void)changeEmployee
{
    _currentEmployeeIndex = (_currentEmployeeIndex + 1) % [self.employees count];
    self.employeeView.employee = [self.employees objectAtIndex:_currentEmployeeIndex];
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

#pragma mark Actions

- (IBAction)changeEmployee:(id)sender
{
    [self changeEmployee];
}

@end
