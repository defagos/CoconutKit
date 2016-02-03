//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSTimeZone+HLSExtensions.h"

@implementation NSTimeZone (HLSExtensions)

#pragma mark Time zone calculations

- (NSTimeInterval)offsetFromTimeZone:(NSTimeZone *)timeZone forDate:(NSDate *)date
{
    return [self secondsFromGMTForDate:date] - [timeZone secondsFromGMTForDate:date];
}

- (NSDate *)dateWithSameComponentsAsDate:(NSDate *)date fromTimeZone:(NSTimeZone *)timeZone
{
    NSTimeInterval timeZoneOffset = [timeZone offsetFromTimeZone:self forDate:date];
    NSDate *dateInSelf = [date dateByAddingTimeInterval:timeZoneOffset];
    
    // If we crossed the DST transition, we must compensante its effect
    NSTimeInterval dstTransitionCorrection = [self daylightSavingTimeOffsetForDate:date]
        - [self daylightSavingTimeOffsetForDate:dateInSelf];
    return [dateInSelf dateByAddingTimeInterval:dstTransitionCorrection];
}

- (NSDate *)dateByAddingTimeInterval:(NSTimeInterval)timeInterval toDate:(NSDate *)date
{
    NSDate *resultDate = [date dateByAddingTimeInterval:timeInterval];
    
    // If we crossed the DST transition, we must compensante its effect
    NSTimeInterval dstTransitionCorrection = [self daylightSavingTimeOffsetForDate:date]
        - [self daylightSavingTimeOffsetForDate:resultDate];
    return [resultDate dateByAddingTimeInterval:dstTransitionCorrection];
}

- (NSDate *)dateByAddingNumberOfDays:(NSInteger)numberOfDays toDate:(NSDate *)date
{
    return [self dateByAddingTimeInterval:24. * 60. * 60. * numberOfDays toDate:date];
}

- (NSTimeInterval)timeIntervalBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    NSTimeInterval timeInterval = [date1 timeIntervalSinceDate:date2];
    
    // If we crossed the DST transition, we must compensante its effect
    NSTimeInterval dstTransitionCorrection = [self daylightSavingTimeOffsetForDate:date1]
        - [self daylightSavingTimeOffsetForDate:date2];
    return timeInterval + dstTransitionCorrection;
}

@end
