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

+ (NSNumberFormatter *)decimalNumberFormatter
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
