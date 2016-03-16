//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSDateFormatter+HLSExtensions.h"

#import "NSArray+HLSExtensions.h"

@implementation NSDateFormatter (HLSExtensions)

- (NSArray<NSString *> *)orderedWeekdaySymbols
{
    NSArray *weekDays = self.weekdaySymbols;
    // firstWeekday returns indices starting at 1
    NSUInteger offset = [[NSCalendar currentCalendar] firstWeekday] - 1;
    return [weekDays arrayByLeftRotatingNumberOfObjects:offset];
}

- (NSArray<NSString *> *)orderedShortWeekdaySymbols
{
    NSArray *shortWeekDays = self.shortWeekdaySymbols;
    // firstWeekday returns indices starting at 1
    NSUInteger offset = [[NSCalendar currentCalendar] firstWeekday] - 1;
    return [shortWeekDays arrayByLeftRotatingNumberOfObjects:offset];
}

@end
