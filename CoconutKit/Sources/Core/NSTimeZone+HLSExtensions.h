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

/**
 * Return the offset (in seconds) between the receiver and another time zone for a given date. Take into account dailight 
 * saving time issues. For example, if the receiver is at UTC+2 for the given date, while the other time zone is at 
 * UTC-3, the method returns 1800 (5 * 60 * 60). If the receiver is UTC+1 for the given date, while the other time zone
 * is at UTC+5, the method returns -1440 (-4 * 60 * 60)
 */
- (NSTimeInterval)offsetFromTimeZone:(NSTimeZone *)timeZone forDate:(NSDate *)date;

/**
 * Return the date which has, in the receiver time zone, the same components as a given date in another time zone. For
 * example, if date corresponds to 2012-03-01 06:12:00 for some timeZone, the method returns the date object which
 * corresponds to 2012-03-01 06:12:00 for self.
 * This method takes into account dailight saving time issues.
 */
- (NSDate *)dateWithSameComponentsAsDate:(NSDate *)date fromTimeZone:(NSTimeZone *)timeZone;

@end
