//
//  LabelBindingsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemoViewController.h"

#import "DemoFormatter.h"

@implementation LabelBindingsDemoViewController

- (NSString *)currentDate
{
    return [DemoFormatter stringFromDate:[NSDate date]];
}

@end
