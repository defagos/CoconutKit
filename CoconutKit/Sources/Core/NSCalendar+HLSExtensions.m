//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSCalendar+HLSExtensions.h"

#import "NSTimeZone+HLSExtensions.h"

@implementation NSCalendar (HLSExtensions)

- (NSInteger)numberOfDaysInUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    NSTimeInterval interval = 0.;
    [self rangeOfUnit:unit
            startDate:NULL
             interval:&interval
              forDate:date];
    return round(interval / (24 * 60 * 60));
}

- (NSDate *)startDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    NSDate *startDateOfUnit = nil;
    [self rangeOfUnit:unit
            startDate:&startDateOfUnit
             interval:NULL
              forDate:date];
    return startDateOfUnit;
}

- (NSDate *)endDateOfUnit:(NSCalendarUnit)unit containingDate:(NSDate *)date
{
    NSUInteger numberOfDaysInUnit = [self numberOfDaysInUnit:unit containingDate:date];
    NSDate *startDateOfUnit = [self startDateOfUnit:unit containingDate:date];
    return [self.timeZone dateByAddingNumberOfDays:numberOfDaysInUnit toDate:startDateOfUnit];
}

- (NSDate *)dateAtNoonTheSameDayAsDate:(NSDate *)date
{
    return [self dateAtHour:12 minute:0 second:0 theSameDayAsDate:date];
}

- (NSDate *)dateAtMidnightTheSameDayAsDate:(NSDate *)date
{
    return [self dateAtHour:0 minute:0 second:0 theSameDayAsDate:date];
}

- (NSDate *)dateAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second theSameDayAsDate:(NSDate *)date
{
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents = [self components:unitFlags fromDate:date];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];
    return [self dateFromComponents:dateComponents];
}

- (NSComparisonResult)compareDaysBetweenDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents1 = [self components:unitFlags fromDate:date1];
    NSDateComponents *dateComponents2 = [self components:unitFlags fromDate:date2];
    
    // Create comparable strings from those components
    NSString *dateString1 = [NSString stringWithFormat:@"%ld%02ld%02ld",
                             (long)[dateComponents1 year],
                             (long)[dateComponents1 month],
                             (long)[dateComponents1 day]];
    NSString *dateString2 = [NSString stringWithFormat:@"%ld%02ld%02ld",
                             (long)[dateComponents2 year],
                             (long)[dateComponents2 month],
                             (long)[dateComponents2 day]];
    
    return [dateString1 compare:dateString2];
}

- (BOOL)isDate:(NSDate *)date1 theSameDayAsDate:(NSDate *)date2
{
    return [self compareDaysBetweenDate:date1 andDate:date2] == NSOrderedSame;
}

@end

@implementation NSDateComponents (HLSExtensionsPrivate)

#pragma mark Class methods

+ (NSString *)stringForComponentValue:(NSInteger)componentValue
{
    if (componentValue != NSDateComponentUndefined) {
        return [NSString stringWithFormat:@"%ld", (long)componentValue];
    }
    else {
        return @"undefined";
    }
}

@end
