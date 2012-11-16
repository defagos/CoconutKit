//
//  NSDateFormatter+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 06.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSDateFormatter+HLSExtensions.h"

#import "NSArray+HLSExtensions.h"

@implementation NSDateFormatter (HLSExtensions)

+ (NSArray *)orderedWeekdaySymbols
{
    static NSArray *s_orderedWeekdays = nil;
    if (! s_orderedWeekdays) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        NSArray *weekDays = [dateFormatter weekdaySymbols];
        // firstWeekday returns indices starting at 1
        NSUInteger offset = [[NSCalendar currentCalendar] firstWeekday] - 1;
        s_orderedWeekdays = [[weekDays arrayByLeftRotatingNumberOfObjects:offset] retain];
    }
    return s_orderedWeekdays;
}

+ (NSArray *)orderedShortWeekdaySymbols
{
    static NSArray *s_orderedShortWeekdays = nil;
    if (! s_orderedShortWeekdays) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        NSArray *shortWeekDays = [dateFormatter shortWeekdaySymbols];
        // firstWeekday returns indices starting at 1
        NSUInteger offset = [[NSCalendar currentCalendar] firstWeekday] - 1;
        s_orderedShortWeekdays = [[shortWeekDays arrayByLeftRotatingNumberOfObjects:offset] retain];
    }
    return s_orderedShortWeekdays;
}

@end
