//
//  LabelBindingsDemo1ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo1ViewController.h"

#import "DemoFormatter.h"
#import "Employee.h"

@interface LabelBindingsDemo1ViewController ()

@property (nonatomic, strong) NSArray *employees;

@end

@implementation LabelBindingsDemo1ViewController

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

- (NSString *)currentDateString
{
    return [DemoFormatter stringFromDate:[NSDate date]];
}

- (NSDate *)currentDate
{
    return [NSDate date];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    return [DemoFormatter stringFromDate:date];
}

- (Employee *)firstEmployee
{
    return [self.employees firstObject];
}

@end
