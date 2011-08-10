//
//  NSCalendar+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 01.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSCalendar+HLSExtensions.h"

#import "HLSCategoryLinker.h"

HLSLinkCategory(NSCalendar_HLSExtensions)

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

- (NSUInteger)numberOfDaysInMonthContainingDate:(NSDate *)date
{
    NSRange daysRange = [self rangeOfUnit:NSDayCalendarUnit
                                   inUnit:NSMonthCalendarUnit 
                                  forDate:date];
    return daysRange.length;    
}

- (NSUInteger)numberOfDaysInMonthContainingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self numberOfDaysInMonthContainingDate:dateInTimeZone];
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self rangeOfUnit:smaller inUnit:larger forDate:dateInTimeZone];
}

- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self ordinalityOfUnit:smaller inUnit:larger forDate:dateInTimeZone];
}

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self rangeOfUnit:unit startDate:datep interval:tip forDate:dateInTimeZone];
}

@end
