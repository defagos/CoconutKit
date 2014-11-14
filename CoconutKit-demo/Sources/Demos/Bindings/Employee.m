//
//  Employee.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 16.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "Employee.h"

#import "DemoTransformer.h"

@implementation Employee

#pragma mark Class methods

+ (NSArray *)employees;
{
    static dispatch_once_t s_onceToken;
    static NSArray *s_employees;
    dispatch_once(&s_onceToken, ^{
        NSString *employeesFilePath = [[NSBundle mainBundle] pathForResource:@"Employees" ofType:@"plist"];
        NSArray *fullNames = [NSArray arrayWithContentsOfFile:employeesFilePath];
        
        NSMutableArray *employees = [NSMutableArray array];
        for (NSString *fullName in fullNames) {
            Employee *employee = [[Employee alloc] init];
            employee.fullName = fullName;
            employee.age = @(arc4random_uniform(40) + 20);
            [employees addObject:employee];
        }
        s_employees = [NSArray arrayWithArray:employees];
        
    });
    return s_employees;
}

#pragma mark Transformers

+ (NSNumberFormatter *)employeeNumberFormatter
{
    return [DemoTransformer decimalNumberFormatter];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; fullName: %@; age: %@>",
            [self class],
            self,
            self.fullName,
            self.age];
}

@end
