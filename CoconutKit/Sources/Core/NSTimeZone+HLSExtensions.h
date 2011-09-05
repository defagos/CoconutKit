//
//  NSTimeZone+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 05.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSTimeZone (HLSExtensions)

/**
 * Return the offset (in seconds) between the receiver and another time zone for a given date. Take into account daily 
 * saving time issues. For example, if the receiver is at UTC+2 for the given date, while the other time zone is at 
 * UTC-3, the method returns 1800 (5 * 60 * 60)
 */
- (NSTimeInterval)offsetFromTimeZone:(NSTimeZone *)timeZone forDate:(NSDate *)date;

@end