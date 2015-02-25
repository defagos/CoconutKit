//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

@interface NSDate (HLSExtensions)

/**
 * Convenience methods for date comparisons. Easier to read than -[NSDate compare:]
 */
- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;
- (BOOL)isLaterThanOrEqualToDate:(NSDate *)date;

@end
