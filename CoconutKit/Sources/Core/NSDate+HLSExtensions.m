//
//  NSDate+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensions.h"

#import "HLSRuntime.h"
#import "HLSCategoryLinker.h"

HLSLinkCategory(NSDate_HLSExtensions)

static id (*s_NSDate__descriptionWithLocale_Imp)(id, SEL, id) = NULL;
static NSDateFormatter *s_dateFormatter = nil;

@interface NSDate (HLSExtensionsPrivate)

- (NSString *)swizzledDescriptionWithLocale:(id)locale;

@end

__attribute__ ((constructor)) static void HLSExtensionsInjectNS(void)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    s_NSDate__descriptionWithLocale_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector([NSDate class], @selector(descriptionWithLocale:), @selector(swizzledDescriptionWithLocale:));
    
    // Create time formatter for system timezone (which is the default one if not set)
    s_dateFormatter = [[NSDateFormatter alloc] init];
    [s_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'ZZZ"];
    
    [pool release];
}

@implementation NSDate (HLSExtensions)

#pragma mark Convenience methods

- (NSDate *)dateSameDayAtNoon
{
    return [self dateSameDayAtHour:12 minute:0 second:0];
}

- (NSDate *)dateSameDayAtNoonInTimeZone:(NSTimeZone *)timeZone
{
    return [self dateSameDayAtHour:12 minute:0 second:0 inTimeZone:timeZone];
}

- (NSDate *)dateSameDayAtMidnight
{
    return [self dateSameDayAtHour:0 minute:0 second:0];
}

- (NSDate *)dateSameDayAtMidnightInTimeZone:(NSTimeZone *)timeZone
{
    return [self dateSameDayAtHour:0 minute:0 second:0 inTimeZone:timeZone];
}

- (NSDate *)dateSameDayAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:self];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];
    return [calendar dateFromComponents:dateComponents];
}

- (NSDate *)dateSameDayAtHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second inTimeZone:(NSTimeZone *)timeZone
{
    // NSDateComponents are calculated using a calendar object. The problem with calendar objects is that they seem to
    // be immutable (a setter for the time zone exists, e.g., but it does not do anything when called). The result is
    // the same whether the calendar object is created via initWithCalendarIdentifier: or using a convenience constructor
    // (and the init method returns nil)
    // The problem is that components are calculated using the time zone associated with the calendar object, and this
    // cannot be changed (I still cannot figure out why in the hell a time zone appears in NSCalendar interface). The 
    // only choice we have to "override" the calendar time zone is therefore to alter the date we have (the receiver) 
    // so that it takes into account the time offset between the calendar time zone (which we cannot change) and timeZone
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[[NSCalendar currentCalendar] timeZone] secondsFromGMT];
    NSDate *dateInTimeZone = [self dateByAddingTimeInterval:timeZoneOffset];
    return [dateInTimeZone dateSameDayAtHour:hour - timeZoneOffset / (60 * 60) 
                                      minute:minute 
                                      second:second];
}

- (NSComparisonResult)compareDayWithDate:(NSDate *)date
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

- (NSComparisonResult)compareDayWithDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    // see comment in dateAtHour:minute:second:inTimeZone:
    NSTimeInterval timeZoneOffset = [timeZone secondsFromGMT] - [[[NSCalendar currentCalendar] timeZone] secondsFromGMT];
    NSDate *selfInTimeZone = [self dateByAddingTimeInterval:timeZoneOffset];
    NSDate *dateInTimeZone = [date dateByAddingTimeInterval:timeZoneOffset];
    return [selfInTimeZone compareDayWithDate:dateInTimeZone];
}

- (BOOL)isSameDayAsDate:(NSDate *)date
{
    NSComparisonResult comparisonResult = [self compareDayWithDate:date];
    return comparisonResult == NSOrderedSame;
}

- (BOOL)isSameDayAsDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone
{
    NSComparisonResult comparisonResult = [self compareDayWithDate:date inTimeZone:timeZone];
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

#pragma mark Injected methods

- (NSString *)swizzledDescriptionWithLocale:(id)locale
{
    NSString *originalString = (*s_NSDate__descriptionWithLocale_Imp)(self, @selector(descriptionWithLocale:), locale);
    return [NSString stringWithFormat:@"%@ (system time zone: %@)", originalString, [s_dateFormatter stringFromDate:self]];
}

@end
