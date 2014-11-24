//
//  NSCalendar+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 01.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSCalendar+HLSExtensions.h"

#import "NSDate+HLSExtensions.h"
#import "NSTimeZone+HLSExtensions.h"

/**
 * The strategy is always the same here: Since all methods available from NSCalendar use the calendar time zone, we
 * always have to convert dates from the time zone in which we want to work to the calendar time zone. In this time 
 * zone we can then apply all methods readily available from NSCalendar. If the result is not a date, we are done. If 
 * the result is a date, though, we need to convert it back to the time zone in which we work
 */

@interface NSDateComponents (HLSExtensionsPrivate)

+ (NSString *)stringForComponentValue:(NSInteger)componentValue;

@end

@implementation NSCalendar (HLSExtensions)

#pragma mark Class methods

+ (NSDate *)dateFromComponents:(NSDateComponents *)components
{
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

+ (NSDate *)dateFromComponents:(NSDateComponents *)components inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] dateFromComponents:components inTimeZone:timeZone];
}

+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
}

+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:date inTimeZone:timeZone];
}

+ (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit
{
    return [[NSCalendar currentCalendar] minimumRangeOfUnit:unit];
}

+ (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit
{
    return [[NSCalendar currentCalendar] maximumRangeOfUnit:unit];
}

+ (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] numberOfDaysInUnit:unit containingDate:date];
}

+ (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] numberOfDaysInUnit:unit containingDate:date inTimeZone:timeZone];
}

+ (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] startDateOfUnit:unit containingDate:date];
}

+ (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] startDateOfUnit:unit containingDate:date inTimeZone:timeZone];
}

+ (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] endDateOfUnit:unit containingDate:date];
}

+ (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] endDateOfUnit:unit containingDate:date inTimeZone:timeZone];
}

+ (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] rangeOfUnit:smaller inUnit:larger forDate:date];
}

+ (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] rangeOfUnit:smaller inUnit:larger forDate:date inTimeZone:timeZone];
}

+ (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] ordinalityOfUnit:smaller inUnit:larger forDate:date];
}

+ (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] ordinalityOfUnit:smaller inUnit:larger forDate:date inTimeZone:timeZone];
}

+ (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate *__autoreleasing *)pStartDate interval:(NSTimeInterval *)pInterval forDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] rangeOfUnit:unit startDate:pStartDate interval:pInterval forDate:date];
}

+ (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate *__autoreleasing *)pStartDate interval:(NSTimeInterval *)pInterval forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] rangeOfUnit:unit startDate:pStartDate interval:pInterval forDate:date inTimeZone:timeZone];
}

+ (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)date options:(NSUInteger)options
{
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:options];
}

+ (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)date options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:options inTimeZone:timeZone];
}

+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startDate toDate:(NSDate *)endDate options:(NSUInteger)options
{
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:startDate toDate:endDate options:options];
}

+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startDate toDate:(NSDate *)endDate options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:startDate toDate:endDate options:options inTimeZone:timeZone];
}

+ (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] dateAtNoonTheSameDayAsDate:date];
}

+ (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] dateAtNoonTheSameDayAsDate:date inTimeZone:timeZone];
}

+ (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] dateAtMidnightTheSameDayAsDate:date];
}

+ (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] dateAtMidnightTheSameDayAsDate:date inTimeZone:timeZone];
}

+ (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date
{
    return [[NSCalendar currentCalendar] dateAtHour:hour minute:minute second:second theSameDayAsDate:date];
}

+ (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] dateAtHour:hour minute:minute second:second theSameDayAsDate:date inTimeZone:timeZone];
}

+ (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    return [[NSCalendar currentCalendar] compareDaysBetweenDate:date1 andDate:date2];
}

+ (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] compareDaysBetweenDate:date1 andDate:date2 inTimeZone:timeZone];
}

+ (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2
{
    return [[NSCalendar currentCalendar] isDate:date1 theSameDayAsDate:date2];
}

+ (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone
{
    return [[NSCalendar currentCalendar] isDate:date1 theSameDayAsDate:date2 inTimeZone:timeZone];
}

#pragma mark Calendrical calculations

- (NSDate *)dateFromComponents:(NSDateComponents *)components inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self dateFromComponents:components];
    }
    
    // The time zone can be specified in the date components. We do not want this method to be called in such cases
    NSAssert(! [components timeZone], @"The time zone must not be specified in the date components");
    
    NSDate *dateInCalendarTimeZone = [self dateFromComponents:components];
    return [timeZone dateWithSameComponentsAsDate:dateInCalendarTimeZone fromTimeZone:[self timeZone]];
}

- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self components:unitFlags fromDate:date];
    }
    
    NSDate *dateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:date fromTimeZone:timeZone];
    NSDateComponents *dateComponents = [self components:unitFlags fromDate:dateInCalendarTimeZone];
    
    if (unitFlags & NSCalendarUnitTimeZone) {
        [dateComponents setTimeZone:timeZone];
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
    if (! timeZone) {
        return [self numberOfDaysInUnit:unit containingDate:date];
    }
    
    NSDate *dateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:date fromTimeZone:timeZone];
    return [self numberOfDaysInUnit:unit containingDate:dateInCalendarTimeZone];
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
    if (! timeZone) {
        return [self startDateOfUnit:unit containingDate:date];
    }
    
    NSDate *dateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:date fromTimeZone:timeZone];
    NSDate *startDateInCalendarTimeZone = [self startDateOfUnit:unit containingDate:dateInCalendarTimeZone];
    return [timeZone dateWithSameComponentsAsDate:startDateInCalendarTimeZone fromTimeZone:[self timeZone]];
}

- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    return [self endDateOfUnit:unit containingDate:date inTimeZone:[self timeZone]];
}

- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self endDateOfUnit:unit containingDate:date];
    }
    
    NSUInteger numberOfDaysInUnit = [self numberOfDaysInUnit:unit containingDate:date inTimeZone:timeZone];
    NSDate *startDateOfUnit = [self startDateOfUnit:unit containingDate:date inTimeZone:timeZone];
    return [timeZone dateByAddingNumberOfDays:numberOfDaysInUnit toDate:startDateOfUnit];
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self rangeOfUnit:smaller inUnit:larger forDate:date];
    }
    
    NSDate *dateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:date fromTimeZone:timeZone];
    return [self rangeOfUnit:smaller inUnit:larger forDate:dateInCalendarTimeZone];
}

- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self ordinalityOfUnit:smaller inUnit:larger forDate:date];
    }
    
    NSDate *dateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:date fromTimeZone:timeZone];
    return [self ordinalityOfUnit:smaller inUnit:larger forDate:dateInCalendarTimeZone];
}

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate *__autoreleasing *)pStartDate interval:(NSTimeInterval *)pInterval forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self rangeOfUnit:unit startDate:pStartDate interval:pInterval forDate:date];
    }
    
    NSDate *dateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:date fromTimeZone:timeZone];
    BOOL result = [self rangeOfUnit:unit startDate:pStartDate interval:pInterval forDate:dateInCalendarTimeZone];
    if (pStartDate) {
        *pStartDate = [timeZone dateWithSameComponentsAsDate:*pStartDate fromTimeZone:[self timeZone]];
    }
    return result;
}

- (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)date options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self dateByAddingComponents:components toDate:date options:options];
    }
    
    NSDate *dateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:date fromTimeZone:timeZone];
    NSDate *resultDateInCalendarTimeZone = [self dateByAddingComponents:components toDate:dateInCalendarTimeZone options:options];
    return [timeZone dateWithSameComponentsAsDate:resultDateInCalendarTimeZone fromTimeZone:[self timeZone]];
}

- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startDate toDate:(NSDate *)endDate options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self components:unitFlags fromDate:startDate toDate:endDate options:options];
    }
    
    NSDate *startDateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:startDate fromTimeZone:timeZone];
    NSDate *endDateInCalendarTimeZone = [[self timeZone] dateWithSameComponentsAsDate:endDate fromTimeZone:timeZone];
    return [self components:unitFlags fromDate:startDateInCalendarTimeZone toDate:endDateInCalendarTimeZone options:options];
}

- (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date
{
    return [self dateAtHour:12 minute:0 second:0 theSameDayAsDate:date];
}

- (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [self dateAtHour:12 minute:0 second:0 theSameDayAsDate:date inTimeZone:timeZone];
}

- (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date
{
    return [self dateAtHour:0 minute:0 second:0 theSameDayAsDate:date];
}

- (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    return [self dateAtHour:0 minute:0 second:0 theSameDayAsDate:date inTimeZone:timeZone];
}

- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date
{
    return [self dateAtHour:hour minute:minute second:second theSameDayAsDate:date inTimeZone:[self timeZone]];
}

- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self dateAtHour:hour minute:minute second:second theSameDayAsDate:date];
    }
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents = [self components:unitFlags fromDate:date inTimeZone:timeZone];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];
    return [self dateFromComponents:dateComponents inTimeZone:timeZone];
}

- (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    return [self compareDaysBetweenDate:date1 andDate:date2 inTimeZone:[self timeZone]];
}

- (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self compareDaysBetweenDate:date1 andDate:date2];
    }
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents1 = [self components:unitFlags fromDate:date1 inTimeZone:timeZone];
    NSDateComponents *dateComponents2 = [self components:unitFlags fromDate:date2 inTimeZone:timeZone];
    
    // Create comparable strings from those components
    NSString *dateString1 = [NSString stringWithFormat:@"%ld%02ld%02ld", 
                             (long)[dateComponents1 year],
                             (long)[dateComponents1 month],
                             (long)[dateComponents1 day]];
    NSString *dateString2 = [NSString stringWithFormat:@"%ld%02ld%02ld", 
                             (long)[dateComponents2 year],
                             (long)[dateComponents2 month],
                             (long)[dateComponents2 day]];
    
    return [dateString1 compare:dateString2];
}

- (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2
{
    return [self isDate:date1 theSameDayAsDate:date2 inTimeZone:[self timeZone]];
}

- (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone
{
    if (! timeZone) {
        return [self isDate:date1 theSameDayAsDate:date2];
    }
    
    NSComparisonResult comparisonResult = [self compareDaysBetweenDate:date1 andDate:date2 inTimeZone:timeZone];
    return comparisonResult == NSOrderedSame;
}

@end

@implementation NSDateComponents (HLSExtensionsPrivate)

#pragma mark Class methods

+ (NSString *)stringForComponentValue:(NSInteger)componentValue
{
    if (componentValue != NSDateComponentUndefined) {
        return [NSString stringWithFormat:@"%ld", (long)componentValue];
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
            "\tweekOfYear: %@\n"
            "\tweekOfMonth: %@\n"
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
            [NSDateComponents stringForComponentValue:[self weekOfYear]],
            [NSDateComponents stringForComponentValue:[self weekOfMonth]],
            [NSDateComponents stringForComponentValue:[self weekday]],
            [NSDateComponents stringForComponentValue:[self weekdayOrdinal]],
            [NSDateComponents stringForComponentValue:[self era]]];
}

@end

