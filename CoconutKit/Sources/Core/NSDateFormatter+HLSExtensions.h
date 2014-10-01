//
//  NSDateFormatter+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 06.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

@interface NSDateFormatter (HLSExtensions)

/**
 * Same as -weekDaySymbols and -shortWeekdaySymbols, but returning the days in the order corresponding to the
 * device international settings. 
 */
+ (NSArray *)orderedWeekdaySymbols;
+ (NSArray *)orderedShortWeekdaySymbols;

@end
