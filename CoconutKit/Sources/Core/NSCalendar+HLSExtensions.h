//
//  NSCalendar+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 01.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Remark:
 * -------
 * For all methods which take a time zone object as parameter, the NSCalendar time zone is ignored. If nil is passed
 * as time zone parameter, the NSCalendar time zone is used, though. Instead of passing nil as time zone, consider
 * using the equivalent method without time zone parameter.
 */
@interface NSCalendar (HLSExtensions)

/**
 * Shortcuts to apply calendrical calculation methods to [NSCalendar currentCalendar]. Refer to the instance method documentation
 * for more information
 */
+ (NSDate *)dateFromComponents:(NSDateComponents *)components;
+ (NSDate *)dateFromComponents:(NSDateComponents *)components inTimeZone:(NSTimeZone *)timeZone;
+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date;
+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit;
+ (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit;
+ (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;
+ (NSUInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;
+ (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;
+ (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
+ (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
+ (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)pStartDate interval:(NSTimeInterval *)pInterval forDate:(NSDate *)date;
+ (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)pStartDate interval:(NSTimeInterval *)pInterval forDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)date options:(NSUInteger)options;
+ (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)date options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone;
+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startDate toDate:(NSDate *)endDate options:(NSUInteger)options;
+ (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startDate toDate:(NSDate *)endDate options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date;
+ (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date;
+ (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date;
+ (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
+ (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2;
+ (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone;
+ (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2;
+ (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date corresponding to given components in the specified time zone. The NSCalendar time zone is ignored
 * This function plays the same role as the NSDateComponents setTimeZone: instance method which is available starting 
 * with iOS 4.
 * If you are targeting iOS 4 or higher, you therefore have two options:
 *   - either use dateFromComponents:inTimeZone:
 *   - or use dateFromComponents: with the time zone set using setTimeZone:
 * You must not attempt to call dateFromComponents:inTimeZone: if a time zone has been set using setTimeZone:
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
 * Return the start date of the unit containing a given date. This method uses the time zone associated with the calendar. For
 * example, if unit is NSWeekCalendarUnit, the method returns the date corresponding to the first day (at midnight) of the week 
 * containing the given date
 */
- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;

/**
 * Same as startDateOfUnit:containingDate:, except that the given time zone is used. The NSCalendar time zone is ignored
 */
- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as startDateOfUnit:containingDate:, but returning the first date after the unit. For example, if unit is NSWeekCalendarUnit, 
 * the method returns the date corresponding to the first day (at midnight) of the week after the week to which the given date belongs
 */
- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;

/**
 * Same as endDateOfUnit:containingDate:, except that the given time zone is used. The NSCalendar time zone is ignored
 */
- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

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

/**
 * Same as dateByAddingComponents:toDate:options:, but in the specified time zone. The NSCalendar time zone is ignored
 *
 * Addition of components can be ambiguous. Please refer to the dateByAddingComponents:toDate:options: documentation for more information
 */
- (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)date options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone;

/**
 * Same as components:fromDate:toDate:options:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startDate toDate:(NSDate *)endDate options:(NSUInteger)options inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date corresponding to noon the same day as a given date (for the system calendar and time zone)
 */
- (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date;

/**
 * Same as dateAtNoonTheSameDayAsDate, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date corresponding to midnight the same day as a given date (for the system calendar and time zone)
 */
- (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date;

/**
 * Same as dateAtMidnightTheSameDayAsDate, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the date corresponding to the specified hour / minute / second the same day as a given date (for the system 
 * calendar and time zone)
 */
- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date;

/**
 * Same as dateAtHour:minute:second:theSameDayAsDate:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

/**
 * Compare the days of two given dates (for the system calendar and time zone)
 */
- (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2;

/**
 * Same as compareDaysBetweenDate:andDate:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return YES iff the two dates belong to the same day (for the system calendar and time zone)
 */
- (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2;

/**
 * Same as isDate:theSameDayAsDate:, but in the specified time zone. The NSCalendar time zone is ignored
 */
- (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2 inTimeZone:(NSTimeZone *)timeZone;

@end
