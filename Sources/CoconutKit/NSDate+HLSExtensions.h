//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (HLSExtensions)

/**
 * Convenience methods for date comparisons. Easier to read than -[NSDate compare:]
 */
- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;
- (BOOL)isLaterThanOrEqualToDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
