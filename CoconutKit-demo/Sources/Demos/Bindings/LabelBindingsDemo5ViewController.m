//
//  LabelBindingsDemo5ViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo5ViewController.h"

#import "EmployeeView.h"
#import "TodayView.h"
#import "YesterdayView.h"

@interface LabelBindingsDemo5ViewController ()

@property (nonatomic, weak) IBOutlet UIView *employeePlaceholderView;
@property (nonatomic, weak) IBOutlet UIView *todayPlaceholderView;
@property (nonatomic, weak) IBOutlet UIView *yesterdayPlaceholderView;

@end

@implementation LabelBindingsDemo5ViewController

#pragma mark Accessors and mutators

- (NSDate *)currentDate
{
    return [NSDate date];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // When instantiated, no -currentDate method is available along the responder chain starting with TodayView (in fact,
    // there is no responder chain, the view is dangling since it has not been added to a view hierarchy). After the view
    // has been added to the parent view hierarchy, and if we want to access the -currentDate method, we need to recalculate
    // the bindings (refreshing them does not suffice since the information is cached)
    TodayView *todayView = [TodayView view];
    [self.todayPlaceholderView addSubview:todayView];
    
    // The method -yesterdayDate is on YesterdayView, bindings can therefore be resolved at view creation time
    YesterdayView *yesterdayView = [YesterdayView view];
    [self.yesterdayPlaceholderView addSubview:yesterdayView];
    
    Employee *employee = [[Employee alloc] init];
    employee.fullName = @"David Fisher";
    employee.age = @37;
    
    EmployeeView *employeeView = [EmployeeView view];
    employeeView.employee = employee;
    [self.employeePlaceholderView addSubview:employeeView];
}

#pragma mark Action callbacks

- (IBAction)refresh:(id)sender
{
    [self refreshBindingsForced:NO];
}

- (IBAction)recalculate:(id)sender
{
    [self refreshBindingsForced:YES];
}

@end
