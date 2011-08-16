//
//  NSDate+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

@interface NSDate (HLSExtensions)

/**
 * Return the date corresponding to noon the same day as the receiver (for the system calendar and time zone)
 */
- (NSDate *)dateSameDayAtNoon;

/**
 * Return the date corresponding to noon the same day as the receiver (for the system calendar and for the given 
 * time zone)
 */
- (NSDate *)dateSameDayAtNoonInTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date corresponding to midnight the same day as the receiver (for the system calendar and time zone)
 */
- (NSDate *)dateSameDayAtMidnight;

/**
 * Return the date corresponding to midnight the same day as the receiver (for the system calendar and for the given 
 * time zone)
 */
- (NSDate *)dateSameDayAtMidnightInTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date corresponding to the specified hour / minute / second the same day as the receiver (for the system 
 * calendar and time zone)
 */
- (NSDate *)dateSameDayAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

/**
 * Return the date corresponding to the specified hour / minute / second the same day as the receiver (for the system 
 * calendar and for the given time zone)
 */
- (NSDate *)dateSameDayAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second inTimeZone:(NSTimeZone *)timeZone;

/**
 * Compare the receiver with another date (for the system calendar and time zone)
 */
- (NSComparisonResult)compareDayWithDate:(NSDate *)date;

/**
 * Compare the receiver with another date (for the system calendar and for the given time zone)
 */
- (NSComparisonResult)compareDayWithDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Compare the day part of the receiver with the one of another date (for the system calendar and time zone)
 */
- (BOOL)isSameDayAsDate:(NSDate *)date;

/**
 * Compare the day part of the receiver with the one of another date (for the system calendar and for the given time zone)
 */
- (BOOL)isSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the start date of the week the receiver belongs to, taking system calendar and time zone settings into account (return 
 * Sundays if US regional settings, or Mondays if CH regional settings, for example)
 */
- (NSDate *)startDateOfTheWeek;

/**
 * Return the start date of the week the receiver belongs to, taking system calendar and the given time zone into account (return 
 * Sundays if US regional settings, or Mondays if CH regional settings, for example)
 */
- (NSDate *)startDateOfTheWeekInTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as startDateOfTheWeek, but returning the first date not belonging to the week (week = [startDate, endDate[)
 */
- (NSDate *)endDateOfTheWeek;

/**
 * Same as startDateOfTheWeekInTimeZone:, but returning the first date not belonging to the week (week = [startDate, endDate[)
 */
- (NSDate *)endDateOfTheWeekInTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the start date of the month the receiver belongs to, taking system calendar and time zone settings into account
 */
- (NSDate *)startDateOfTheMonth;

/**
 * Return the start date of the month the receiver belongs to, taking system calendar and the given time zone into account
 */
- (NSDate *)startDateOfTheMonthInTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as startDateOfTheMonth, but returning the first date not belonging to the month (month = [startDate, endDate[)
 */
- (NSDate *)endDateOfTheMonth;

/**
 * Same as startDateOfTheMonthInTimeZone:, but returning the first date not belonging to the month (month = [startDate, endDate[)
 */
- (NSDate *)endDateOfTheMonthInTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the start date of the year the receiver belongs to, taking system calendar and time zone settings into account
 */
- (NSDate *)startDateOfTheYear;

/**
 * Return the start date of the year the receiver belongs to, taking system calendar and the given time zone into account
 */
- (NSDate *)startDateOfTheYearInTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as startDateOfTheYear, but returning the first date not belonging to the year (year = [startDate, endDate[)
 */
- (NSDate *)endDateOfTheYear;

/**
 * Same as startDateOfTheYearInTimeZone:, but returning the first date not belonging to the year (year = [startDate, endDate[)
 */
- (NSDate *)endDateOfTheYearInTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date obtained by adding some number of days to the receiver (can be negative for days in the past)
 */
- (NSDate *)dateByAddingNumberOfDays:(NSInteger)numberOfDays;

@end
