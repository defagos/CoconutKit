//
//  NSDate+HLSExtensions.h
//  nut
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

@interface NSDate (HLSExtensions)

/**
 * Sometimes it is just easier to work with dates at noon to avoid issues regarding timezones. This method
 * just return the receiver date at noon
 */
- (NSDate *)dateAtNoon;

/**
 * Compare the receiver with another date
 */
- (NSComparisonResult)compareDaysWithDate:(NSDate *)date;

/**
 * Compare the day part of the receiver with the one of another date
 */
- (BOOL)isSameDayAsDate:(NSDate *)date;

/**
 * Return the first day of the week the receiver belongs to, taking regional settings into account (return Sundays if US regional 
 * settings, or Mondays if CH regional settings, for example)
 */
- (NSDate *)firstDayOfTheWeek;

@end
