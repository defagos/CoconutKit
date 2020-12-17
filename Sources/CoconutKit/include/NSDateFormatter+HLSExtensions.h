//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSDateFormatter (HLSExtensions)

/**
 * Same as -weekDaySymbols and -shortWeekdaySymbols, but returning the days in the order corresponding to the
 * device international settings. 
 */
@property (nonatomic, readonly) NSArray <NSString *> *orderedWeekdaySymbols;
@property (nonatomic, readonly) NSArray <NSString *> *orderedShortWeekdaySymbols;

@end

NS_ASSUME_NONNULL_END
