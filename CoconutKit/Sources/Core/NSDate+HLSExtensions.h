//
//  NSDate+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Remark:
 * -------
 * For all methods which take a time zone object as parameter, the system time zone is ignored. If nil is passed
 * as time zone parameter, the system time zone is used, though. Instead of passing nil as time zone, consider
 * using the equivalent method without time zone parameter.
 */
@interface NSDate (HLSExtensions)

/**
 * Convenience methods for date comparisons. Easier to read than - [NSDate compare:]
 */
- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;
- (BOOL)isLaterThanOrEqualToDate:(NSDate *)date;

@end
