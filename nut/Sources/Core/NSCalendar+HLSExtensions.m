//
//  NSCalendar+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 01.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSCalendar+HLSExtensions.h"

@implementation NSCalendar (HLSExtensions)

- (NSDate *)dateFromComponents:(NSDateComponents *)components inTimeZone:(NSTimeZone *)timeZone
{
    NSDate *dateInCalendarTimeZone = [self dateFromComponents:components];
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    return [dateInCalendarTimeZone dateByAddingTimeInterval:-timeZoneOffset];
}

- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self components:unitFlags fromDate:dateInTimeZone];
}

@end
