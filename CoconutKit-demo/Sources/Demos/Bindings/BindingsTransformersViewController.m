//
//  BindingsTransformersViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "BindingsTransformersViewController.h"

#import "DemoTransformer.h"
#import "Employee.h"

@interface BindingsTransformersViewController ()

@end

@implementation BindingsTransformersViewController

#pragma mark Accessors and mutators

- (Employee *)employee
{
    return [[Employee employees] firstObject];
}

- (NSArray *)employees
{
    return [Employee employees];
}

- (NSDate *)date
{
    return [NSDate date];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Transformers", nil);
}

#pragma mark Transformers

+ (NSDateFormatter *)classDateFormatter
{
    return [DemoTransformer mediumDateFormatter];
}

- (NSDateFormatter *)instanceDateFormatter
{
    return [DemoTransformer mediumDateFormatter];
}

@end
