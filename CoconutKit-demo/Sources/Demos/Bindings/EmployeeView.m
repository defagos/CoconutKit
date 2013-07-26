//
//  EmployeeView.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "EmployeeView.h"

@implementation EmployeeView

#pragma mark Accessors and mutators

- (void)setEmployee:(Employee *)employee
{
    _employee = employee;
    
    [self bindToObject:nil];
}

@end
