//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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

+ (NSNumberFormatter *)employeeClassNumberFormatter
{
    return [DemoTransformer decimalNumberFormatter];
}

- (NSNumberFormatter *)employeeInstanceNumberFormatter
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
