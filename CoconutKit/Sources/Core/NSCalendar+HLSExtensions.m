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
#import "NSTimeZone+HLSExtensions.h"

HLSLinkCategory(NSCalendar_HLSExtensions)

@interface NSDateComponents (HLSExtensionsPrivate)

+ (NSString *)stringForComponentValue:(NSInteger)componentValue;

@end

@implementation NSCalendar (HLSExtensions)

- (NSDate *)dateFromComponents:(NSDateComponents *)components inTimeZone:(NSTimeZone *)timeZone
{
    // iOS 4 and above: The time zone can be specified in the date components. We do not want this method to be called 
    // in such cases
    // TODO: When iOS 4 and above required: Can remove respondsToSelector test
    NSAssert(! [components respondsToSelector:@selector(timeZone)] || ! [components timeZone], 
             @"The time zone must not be specified in the date components");
    
    NSDate *dateInCalendarTimeZone = [self dateFromComponents:components];
    NSTimeInterval timeZoneOffset = [timeZone offsetFromTimeZone:[self timeZone] forDate:dateInCalendarTimeZone];
    return [dateInCalendarTimeZone dateByAddingTimeInterval:-timeZoneOffset];
}

- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone offsetFromTimeZone:[self timeZone] forDate:date];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    
    // If we crossed the DST transition in the calendar time zone, we must compensante its effect
    NSTimeInterval dstTransitionCorrection = [[self timeZone] daylightSavingTimeOffsetForDate:date]
        - [[self timeZone] daylightSavingTimeOffsetForDate:dateInTimeZone];
    dateInTimeZone = [dateInTimeZone dateByAddingTimeInterval:dstTransitionCorrection];
    
    NSDateComponents *dateComponents = [self components:unitFlags fromDate:dateInTimeZone];
    
    // iOS 4 and above: NSTimeZoneCalendarUnit = (1 << 21)
    // TODO: When iOS 4 and above required: Can use NSTimeZoneCalendarUnit and remove respondsToSelector test
    if (unitFlags & (1 << 21)) {
        if ([dateComponents respondsToSelector:@selector(setTimeZone:)]) {
            [dateComponents setTimeZone:timeZone];
        }
    }
    return dateComponents;
}

- (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    NSTimeInterval interval = 0.;
    [self rangeOfUnit:unit
            startDate:NULL 
             interval:&interval 
              forDate:date];
    return round(interval / (24 * 60 * 60));
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
    return [[self startDateOfUnit:unit containingDate:date] dateSameTimeByAddingNumberOfDays:numberOfDaysInUnit];
}

- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSUInteger numberOfDaysInUnit = [self numberOfDaysInUnit:unit containingDate:date inTimeZone:timeZone];
    return [[self startDateOfUnit:unit containingDate:date inTimeZone:timeZone] dateSameTimeByAddingNumberOfDays:numberOfDaysInUnit];
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

@implementation NSDateComponents (HLSExtensionsPrivate)

#pragma mark Class methods

+ (NSString *)stringForComponentValue:(NSInteger)componentValue
{
    if (componentValue != NSUndefinedDateComponent) {
        return [NSString stringWithFormat:@"%d", componentValue];
    }
    else {
        return @"undefined";
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p;\n"
            "\tyear: %@\n"
            "\tmonth: %@\n"
            "\tday: %@\n"
            "\thour: %@\n"
            "\tminute: %@\n"
            "\tsecond: %@\n"
            "\tweek: %@\n"
            "\tweekday: %@\n"
            "\tweekdayOrdinal: %@\n"
            "\tera: %@\n"
            ">", 
            [self class],
            self,
            [NSDateComponents stringForComponentValue:[self year]],
            [NSDateComponents stringForComponentValue:[self month]],
            [NSDateComponents stringForComponentValue:[self day]],
            [NSDateComponents stringForComponentValue:[self hour]],
            [NSDateComponents stringForComponentValue:[self minute]],
            [NSDateComponents stringForComponentValue:[self second]],
            [NSDateComponents stringForComponentValue:[self week]],
            [NSDateComponents stringForComponentValue:[self weekday]],
            [NSDateComponents stringForComponentValue:[self weekdayOrdinal]],
            [NSDateComponents stringForComponentValue:[self era]]];
}

@end

