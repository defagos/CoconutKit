//
//  LabelBindingsDemo4InsetViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo4InsetViewController.h"

@implementation LabelBindingsDemo4InsetViewController

#pragma mark Accessors and mutators

- (NSDate *)tomorrowDate
{
    return [[NSTimeZone systemTimeZone] dateByAddingNumberOfDays:1 toDate:[NSDate date]];
}

@end
