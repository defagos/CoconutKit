//
//  NSCalendar+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 01.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSCalendar+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "NSDate+HLSExtensions.h"

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

- (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    NSTimeInterval interval = 0.;
    [self rangeOfUnit:unit
            startDate:NULL 
             interval:&interval 
              forDate:date];
    return interval / (24 * 60 * 60);
}

- (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [self numberOfDaysInUnit:unit containingDate:dateInTimeZone];
}

- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    NSDate *startDateOfUnit = nil;
    [self rangeOfUnit:unit 
            startDate:&startDateOfUnit
             interval:NULL
              forDate:date];
    return startDateOfUnit;
}

- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[self timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [[self startDateOfUnit:unit containingDate:dateInTimeZone] dateByAddingTimeInterval:-timeZoneOffset];
}

- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    NSUInteger numberOfDaysInUnit = [self numberOfDaysInUnit:unit containingDate:date];
    return [[self startDateOfUnit:unit containingDate:date] dateByAddingNumberOfDays:numberOfDaysInUnit];
}

- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSUInteger numberOfDaysInUnit = [self numberOfDaysInUnit:unit containingDate:date inTimeZone:timeZone];
    return [[self startDateOfUnit:unit containingDate:date inTimeZone:timeZone] dateByAddingNumberOfDays:numberOfDaysInUnit];
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
    BOOL result = [self rangeOfUnit:unit startDate:pStartDate interval:pInterval forDate:dateInTimeZone];
    if (pStartDate) {
        *pStartDate = [*pStartDate dateByAddingTimeInterval:-timeZoneOffset];
    }
    return result;
}

@end
