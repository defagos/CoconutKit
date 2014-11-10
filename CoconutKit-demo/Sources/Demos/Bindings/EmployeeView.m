//
//  EmployeeView.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "EmployeeView.h"

@implementation EmployeeView

#pragma mark Object creation and destruction

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

@end
