//
//  NSDate+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensions.h"

@implementation NSDate (HLSExtensions)

- (NSDate *)dateAtNoon
{
    return [self dateAtHour:12 minute:0 second:0];
}

- (NSDate *)dateAtMidnight
{
    return [self dateAtHour:0 minute:0 second:0];
}

- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:self];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];
    return [calendar dateFromComponents:dateComponents];
}

- (NSComparisonResult)compareDaysWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents *dateComponents2 = [calendar components:unitFlags fromDate:date];
    
    // Create comparable strings from those components
    NSString *dateString1 = [NSString stringWithFormat:@"%d%02d%02d", 
                             [dateComponents1 year],
                             [dateComponents1 month],
                             [dateComponents1 day]];
    NSString *dateString2 = [NSString stringWithFormat:@"%d%02d%02d", 
                             [dateComponents2 year],
                             [dateComponents2 month],
                             [dateComponents2 day]];
    
    return [dateString1 compare:dateString2];
}

- (BOOL)isSameDayAsDate:(NSDate *)date
{
    NSComparisonResult comparisonResult = [self compareDaysWithDate:date];
    return comparisonResult == NSOrderedSame;
}

- (NSDate *)firstDayOfTheWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDayOfWeek = nil;
    [calendar rangeOfUnit:NSWeekCalendarUnit 
                startDate:&firstDayOfWeek
                 interval:NULL
                  forDate:self];
    return firstDayOfWeek;
}

- (NSDate *)dateByAddingNumberOfDays:(NSInteger)numberOfDays
{
    return [self dateByAddingTimeInterval:24 * 60 * 60 * numberOfDays];
}

@end
