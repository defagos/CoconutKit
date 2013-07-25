//
//  LabelBindingsDemo2ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo2ViewController.h"

#import "Employee.h"

@implementation LabelBindingsDemo2ViewController

- (id)init
{
    if (self = [super init]) {
        Employee *employee = [[Employee alloc] init];
        employee.fullName = @"Jessie Pinkman";
        employee.age = @22;
        
        // Can be bound early. The object is retained
        [self bindToObject:employee];
    }
    return self;
}

@end
