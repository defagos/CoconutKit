//
//  LabelBindingsDemo5ViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo5ViewController.h"

#import "DemoFormatter.h"
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

#pragma mark Formatters

- (NSString *)stringFromDate:(NSDate *)date
{
    return [DemoFormatter stringFromDate:date];
}

- (NSString *)stringFromNumber:(NSNumber *)number
{
    return [DemoFormatter stringFromNumber:number];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Bindings are resolved as late as possible (when the view is displayed). In this case, when bindings are resolved,
    // todayView is already in its view hierarchy, so that the binding keypaths and formatters can be resolved at runtime
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

@end
