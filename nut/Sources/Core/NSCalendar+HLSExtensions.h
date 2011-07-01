//
//  NSCalendar+HLSExtensions.h
//  nut
//
//  Created by Samuel Défago on 01.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSCalendar (HLSExtensions)

/**
 * Return the date corresponding to given components in the specified timezone. The NSCalendar time zone is ignored
 */
- (NSDate *)dateFromComponents:(NSDateComponents *)components inTimeZone:(NSTimeZone *)timeZone;

/**
 * Return the components for a given date in the specified timezone. The NSCalendar time zone is ignored
 */
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;

@end
