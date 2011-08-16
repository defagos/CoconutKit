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

- (NSUInteger)numberOfDaysInWeek
{
    NSTimeInterval interval = 0.;
    [self rangeOfUnit:NSWeekCalendarUnit
            startDate:NULL 
             interval:&interval 
              forDate:[NSDate date]     /* any date can be used, all weeks have the same length */];
    return interval / (24 * 60 * 60);    
}

- (NSUInteger)numberOfDaysInMonthContainingDate:(NSDate *)date
{
    NSTimeInterval interval = 0.;
    [self rangeOfUnit:NSMonthCalendarUnit
            startDate:NULL 
             interval:&interval 
              forDate:date];
    return interval / (24 * 60 * 60);    
}

- (NSUInteger)numberOfDaysInMonthContainingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self numberOfDaysInMonthContainingDate:dateInTimeZone];
}

- (NSUInteger)numberOfDaysInYearContainingDate:(NSDate *)date
{
    NSTimeInterval interval = 0.;
    [self rangeOfUnit:NSYearCalendarUnit
            startDate:NULL 
             interval:&interval 
              forDate:date];
    return interval / (24 * 60 * 60);    
}

- (NSUInteger)numberOfDaysInYearContainingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self numberOfDaysInYearContainingDate:dateInTimeZone];
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

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)pStartDate interval:(NSTimeInterval *)pInterval forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self rangeOfUnit:unit startDate:pStartDate interval:pInterval forDate:dateInTimeZone];
}

@end
