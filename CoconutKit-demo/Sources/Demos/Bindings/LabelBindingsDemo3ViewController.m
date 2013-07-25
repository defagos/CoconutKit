//
//  LabelBindingsDemo3ViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo3ViewController.h"

#import "Employee.h"
#import "LabelBindingsDemo3InsetViewController.h"

@implementation LabelBindingsDemo3ViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        LabelBindingsDemo3InsetViewController *insetViewController = [[LabelBindingsDemo3InsetViewController alloc] init];
        [self setInsetViewController:insetViewController atIndex:0];
        
        Employee *employee = [[Employee alloc] init];
        employee.fullName = @"Nate Fisher";
        employee.age = @40;
        [self bindToObject:employee];
    }
    return self;
}

#pragma mark Action callbacks

- (IBAction)refresh:(id)sender
{
    [self refreshBindings];
}

@end
