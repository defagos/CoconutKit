//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

/**
 * To perform calculations for another time zone, instantiate a new calendar and set its time zone. Then call calendrical
 * calculation methods on this calendar
 */
@interface NSCalendar (Extensions)

/**
 * Given a date, return the number of days in the unit containing it. For example, if the date corresponds to some date in March, 
 * the method will return 31 if unit is NSMonthCalendarUnit, and usually 365 if unit is NSYearCalendarUnit (366 for leap years)
 */
- (NSInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;

/**
 * Return the start date of the unit containing a given date. For example, if unit is NSWeekCalendarUnit, the method returns the 
 * date corresponding to the first day (at midnight) of the week containing the given date
 */
- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;

/**
 * Same as -startDateOfUnit:containingDate:, but returning the first date after the unit. For example, if unit is NSWeekCalendarUnit,
 * the method returns the date corresponding to the first day (at midnight) of the week after the week to which the given date belongs
 */
- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date;

/**
 * Return the date corresponding to noon the same day as a given date
 */
- (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date;

/**
 * Return the date corresponding to midnight the same day as a given date
 */
- (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date;

/**
 * Return the date corresponding to the specified hour / minute / second the same day as a given date
 */
- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date;

/**
 * Compare the days of two given dates
 */
- (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2;

/**
 * Return YES iff the two dates belong to the same day
 */
- (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2;

@end
