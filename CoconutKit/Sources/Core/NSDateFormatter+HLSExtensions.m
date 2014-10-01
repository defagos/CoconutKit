//
//  NSDateFormatter+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 06.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSDateFormatter+HLSExtensions.h"

#import "NSArray+HLSExtensions.h"

@implementation NSDateFormatter (HLSExtensions)

+ (NSArray *)orderedWeekdaySymbols
{
    static NSArray *s_orderedWeekdays = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSArray *weekDays = [dateFormatter weekdaySymbols];
        // firstWeekday returns indices starting at 1
        NSUInteger offset = [[NSCalendar currentCalendar] firstWeekday] - 1;
        s_orderedWeekdays = [weekDays arrayByLeftRotatingNumberOfObjects:offset];
    });
    return s_orderedWeekdays;
}

+ (NSArray *)orderedShortWeekdaySymbols
{
    static NSArray *s_orderedShortWeekdays = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSArray *shortWeekDays = [dateFormatter shortWeekdaySymbols];
        // firstWeekday returns indices starting at 1
        NSUInteger offset = [[NSCalendar currentCalendar] firstWeekday] - 1;
        s_orderedShortWeekdays = [shortWeekDays arrayByLeftRotatingNumberOfObjects:offset];
    });
    return s_orderedShortWeekdays;
}

@end
