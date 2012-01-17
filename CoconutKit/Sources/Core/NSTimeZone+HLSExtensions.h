//
//  NSTimeZone+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 05.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSTimeZone (HLSExtensions)

/**
 * Shortcuts to apply time zone calculation methods to [NSTimeZone systemTimeZone]. Refer to the instance method documentation
 * for more information
 */
+ (NSTimeInterval)offsetFromTimeZone:(NSTimeZone *)timeZone forDate:(NSDate *)date;
+ (NSDate *)dateWithSameComponentsAsDate:(NSDate *)date fromTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateByAddingTimeInterval:(NSTimeInterval)timeInterval toDate:(NSDate *)date;
+ (NSDate *)dateByAddingNumberOfDays:(NSInteger)numberOfDays toDate:(NSDate *)date;
+ (NSTimeInterval)timeIntervalBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2;

/**
 * Return the offset (in seconds) between the receiver and another time zone for a given date. Take into account daylight 
 * saving time issues. For example, if the receiver is at UTC+2 for the given date, while the other time zone is at 
 * UTC-3, the method returns 1800 (5 * 60 * 60). If the receiver is UTC+1 for the given date, while the other time zone
 * is at UTC+5, the method returns -1440 (-4 * 60 * 60)
 */
- (NSTimeInterval)offsetFromTimeZone:(NSTimeZone *)timeZone forDate:(NSDate *)date;

/**
 * Return the date which, in the receiver time zone, has the same components as a given date in another time zone. For
 * example, if date corresponds to 2012-03-01 06:12:00 for some timeZone, the method returns the date object which
 * corresponds to 2012-03-01 06:12:00 for the receiver.
 * This method takes into account daylight saving time issues.
 */
- (NSDate *)dateWithSameComponentsAsDate:(NSDate *)date fromTimeZone:(NSTimeZone *)timeZone;

/**
 * Add some number of seconds to a date, taking daylight saving time issues into account. If a DST transition is crossed,
 * a correction is applied so that the date we get is the one we would have expected if no transition had existed. This is 
 * in striking contrast with -[NSDate dateByAddingTimeInterval:] which simply works with date objects (i.e. abstract 
 * points in time) without time zone consideration issues
 *
 * Example:
 * In 2012, the CET -> CEST transition occurs at 2012-03-25 03:00:00 (CEST, UTC+2) for the Europe/Zurich time zone. If you
 * want to add a time interval corresponding to 1 day (86400 seconds) to 2012-03-24 06:00:00 (CET, UTC+1), you now have two
 * options depending on which behavior you require:
 *   - if you use -[NSDate dateByAddingTimeInterval:toDate:], an hour is lost during the transition, and you obtain
 *     2012-03-25 07:00:00 (CEST, UTC+2)
 *   - if you use dateByAddingTimeInterval:toDate:, a one-hour correction is applied to "negate" the transition.
 *     In the end you obtain 2012-03-25 06:00:00 (CEST, UTC+2)
 */
- (NSDate *)dateByAddingTimeInterval:(NSTimeInterval)timeInterval toDate:(NSDate *)date;

/**
 * Same as dateByAddingTimeInterval:toDate:, but using day increments
 */
- (NSDate *)dateByAddingNumberOfDays:(NSInteger)numberOfDays toDate:(NSDate *)date;

/**
 * Return the number of seconds between two given dates (= date1 - date2), taking daylight saving time issues into account.
 * If date1 and date2 are not on the same side of the DST switch date, a correction will be applied. This correction is
 * such that the time difference between date1 and date2 is the one which would have existed if no DST transition had occurred.
 * This is in striking contrast with -[NSDate timeIntervalSinceDate:] which simply works with date objects (i.e. abstract 
 * points in time) without time zone consideration issues
 *
 * Example:
 * In 2012, the CET -> CEST transition occurs at 2012-03-25 03:00:00 (CEST, UTC+2) for the Europe/Zurich time zone. If you
 * want to calculate the time interval between 2012-03-25 03:00:00 (CEST, UTC+2) and 2012-03-25 01:00:00 (CET, UTC+1), you
 * now have two options depending on which behavior you require:
 *   - if you use -[NSDate timeIntervalSinceDate:], you get 3600, i.e. 1 hour (because 02:00:00 UTC+1 does not exist and
 *     waas replaced by 03:00:00 UTC+2)
 *   - if you use timeIntervalBetweenDate:andDate:, you get 7200, i.e. 2 hours (this is the difference between 03:00:00
 *     and 01:00:00, where the CET -> CEST jump has been negated)
 */
- (NSTimeInterval)timeIntervalBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2;

@end
