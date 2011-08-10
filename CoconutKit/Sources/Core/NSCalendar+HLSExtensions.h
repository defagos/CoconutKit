//
//  NSCalendar+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 01.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSCalendar (HLSExtensions)

/**
 * Return the date corresponding to given components in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSDate *)dateFromComponents:(NSDateComponents *)components inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the components for a given date in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Given a date, return the number of days in the month containing it. Uses the NSCalendar time zone
 */
- (NSUInteger)numberOfDaysInMonthContainingDate:(NSDate *)date;

/**
 * Given a date and a time zone, return the number of days in the month containing it. The NSCalendar time zone is ignored
 */
- (NSUInteger)numberOfDaysInMonthContainingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as rangeOfUnit:inUnit:forDate:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as ordinalityOfUnit:inUnit:forDate:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as rangeOfUnit:startDate:interval:forDate:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

@end
