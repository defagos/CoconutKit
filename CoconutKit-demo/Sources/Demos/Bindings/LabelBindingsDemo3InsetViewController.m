//
//  LabelBindingsDemo3InsetViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo3InsetViewController.h"

#import "Employee.h"

@implementation LabelBindingsDemo3InsetViewController

#pragma mark Actions

- (IBAction)change:(id)sender
{
    Employee *employee = [[Employee alloc] init];
    employee.fullName = @"David Fisher";
    employee.age = @35;
    [self bindToObject:employee];
}

@end
