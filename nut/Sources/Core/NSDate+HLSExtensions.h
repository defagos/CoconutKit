//
//  NSDate+HLSExtensions.h
//  nut
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

@interface NSDate (HLSExtensions)

/**
 * Return the receiver at noon (for the system calendar and timezone)
 */
- (NSDate *)dateAtNoon;

/**
 * Return the receiver at midnight (for the system calendar and timezone)
 */
- (NSDate *)dateAtMidnight;

/**
 * Return the receiver at the specified hour / minute / second (for the system calendar and timezone)
 */
- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

/**
 * Compare the receiver with another date (for the system calendar and timezone)
 */
- (NSComparisonResult)compareDaysWithDate:(NSDate *)date;

/**
 * Compare the day part of the receiver with the one of another date (for the system calendar and timezone)
 */
- (BOOL)isSameDayAsDate:(NSDate *)date;

/**
 * Return the first day of the week the receiver belongs to, taking system calendar settings into account (return 
 * Sundays if US regional settings, or Mondays if CH regional settings, for example)
 */
- (NSDate *)firstDayOfTheWeek;

/**
 * Return the date obtained by adding some number of days to the receiver. This number can be negative
 */
- (NSDate *)dateByAddingNumberOfDays:(NSInteger)numberOfDays;

@end
