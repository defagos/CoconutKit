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
 * Return the start date of the unit the receiver belongs to, taking system calendar and time zone settings into account. For
 * example, if unit is NSWeekCalendarUnit, the method returns the date corresponding to the first day (at midnight) of the week 
 * to which the receiver belongs
 */
- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit;

/**
 * Same as startDateOfUnit:, except that the given time zone is used. The NSCalendar time zone is ignored
 */
- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit inTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as startDateOfUnit:, but returning the first date after the unit. For example, if unit is NSWeekCalendarUnit, the method
 * returns the date corresponding to the first day (at midnight) of the week after the week to which the receiver belongs
 */
- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit;

/**
 * Same as endDateOfUnit:, except that the given time zone is used. The NSCalendar time zone is ignored
 */
- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date obtained by adding some number of days to the receiver (can be negative for days in the past)
 */
- (NSDate *)dateByAddingNumberOfDays:(NSInteger)numberOfDays;

@end
