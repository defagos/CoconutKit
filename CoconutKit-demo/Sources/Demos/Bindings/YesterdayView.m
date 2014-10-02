//
//  YesterdayView.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "YesterdayView.h"

@implementation YesterdayView

#pragma mark Accessors and mutators

- (NSDate *)yesterdayDate
{
    return [[NSTimeZone systemTimeZone] dateByAddingNumberOfDays:-1 toDate:[NSDate date]];
}

@end
