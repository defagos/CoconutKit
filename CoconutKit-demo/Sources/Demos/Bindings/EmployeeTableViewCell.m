//
//  EmployeeTableViewCell.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "EmployeeTableViewCell.h"

@implementation EmployeeTableViewCell

#pragma mark Accessors and mutators

- (void)setEmployee:(Employee *)employee
{
    _employee = employee;
    [self bindToObject:employee];
}

#pragma mark Formatters

+ (NSString *)stringFromAge:(NSNumber *)age
{
    return [NSString stringWithFormat:NSLocalizedString(@"Age: %@", nil), age];
}

@end
