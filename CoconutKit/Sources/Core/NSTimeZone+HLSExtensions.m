//
//  NSTimeZone+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 05.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSTimeZone+HLSExtensions.h"

#import "HLSCategoryLinker.h"

HLSLinkCategory(NSTimeZone_HLSExtensions)

@implementation NSTimeZone (HLSExtensions)

- (NSTimeInterval)offsetFromTimeZone:(NSTimeZone *)timeZone forDate:(NSDate *)date
{
    return [self secondsFromGMTForDate:date] - [timeZone secondsFromGMTForDate:date];
}

- (NSDate *)dateWithSameComponentsAsDate:(NSDate *)date fromTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone offsetFromTimeZone:self forDate:date];
    NSDate *dateInSelf = [date dateByAddingTimeInterval:timeZoneOffset];
    
    // If we crossed the DST transition in the calendar time zone, we must compensante its effect
    NSTimeInterval dstTransitionCorrection = [self daylightSavingTimeOffsetForDate:date]
        - [self daylightSavingTimeOffsetForDate:dateInSelf];
    return [dateInSelf dateByAddingTimeInterval:dstTransitionCorrection];
}

- (NSDate *)dateWithSameTimeComponentsByAddingNumberOfDays:(NSInteger)numberOfDays toDate:(NSDate *)date
{
    NSDate *resultDate = [date dateByAddingTimeInterval:24. * 60. * 60. * numberOfDays];
    
    // If we crossed the DST transition in the calendar time zone, we must compensante its effect
    NSTimeInterval dstTransitionCorrection = [self daylightSavingTimeOffsetForDate:date]
        - [self daylightSavingTimeOffsetForDate:resultDate];
    return [resultDate dateByAddingTimeInterval:dstTransitionCorrection];
}

@end
