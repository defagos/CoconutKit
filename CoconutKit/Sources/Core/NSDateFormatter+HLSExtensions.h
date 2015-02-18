//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (HLSExtensions)

/**
 * Same as -weekDaySymbols and -shortWeekdaySymbols, but returning the days in the order corresponding to the
 * device international settings. 
 */
+ (NSArray *)orderedWeekdaySymbols;
+ (NSArray *)orderedShortWeekdaySymbols;

@end
