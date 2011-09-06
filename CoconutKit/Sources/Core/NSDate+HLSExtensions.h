//
//  NSDate+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

@interface NSDate (HLSExtensions)

/**
 * Convenience methods for date comparisons. Easier to read than - [NSDate compare:]
 */
- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;
- (BOOL)isLaterThanOrEqualToDate:(NSDate *)date;

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

@end
