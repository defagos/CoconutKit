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
 * Given a date, return the number of days in the unit containing it, for the time zone associated with the calendar. For 
 * example, if the date corresponds to some date in March, the method will return 31 if unit is NSMonthCalendarUnit, and 
 * usually 365 if unit is NSYearCalendarUnit (366 for leap years)
 */
- (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;

/**
 * Same as numberOfDaysInUnit:containingDate:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

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
- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)pStartDate interval:(NSTimeInterval *)pInterval forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

@end
