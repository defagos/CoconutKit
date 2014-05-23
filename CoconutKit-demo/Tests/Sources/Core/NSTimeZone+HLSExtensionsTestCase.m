//
//  NSTimeZone+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 06.09.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSTimeZone+HLSExtensionsTestCase.h"

@interface NSTimeZone_HLSExtensionsTestCase ()

@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, retain) NSTimeZone *timeZoneZurich;
@property (nonatomic, retain) NSTimeZone *timeZoneTahiti;
@property (nonatomic, retain) NSDate *date1;
@property (nonatomic, retain) NSDate *date2;
@property (nonatomic, retain) NSDate *date3;
@property (nonatomic, retain) NSDate *date4;
@property (nonatomic, retain) NSDate *date5;

@end

@implementation NSTimeZone_HLSExtensionsTestCase

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.calendar = nil;
    self.date1 = nil;
    self.date2 = nil;
    self.date3 = nil;
    self.date4 = nil;
    self.date5 = nil;
    self.timeZoneZurich = nil;
    self.timeZoneTahiti = nil;
    
    [super dealloc];
}

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    // Europe/Zurich uses CEST during summer, between 1:00 UTC on the last Sunday of March and until 1:00 on the last Sunday of October. 
    // CET is used for the rest of the year. Pacific/Tahiti does not use daylight saving times. In summary:
    //   - when Europe/Zurich uses CET (UTC+1): Zurich is 11 hours ahead of Tahiti (UTC-10)
    //   - when Europe/Zurich uses CEST (UTC+2): Zurich is 12 hours ahead of Tahiti (UTC-10)
    self.calendar = [NSCalendar currentCalendar];
    self.timeZoneZurich = [NSTimeZone timeZoneWithName:@"Europe/Zurich"];
    self.timeZoneTahiti = [NSTimeZone timeZoneWithName:@"Pacific/Tahiti"];
    
    // The two dates below correspond to days which are different whether we are in the Zurich time zone or in the Tahiti time zone
    // Date corresponding to the beginning of the year
    
    // For Europe/Zurich, this corresponds to 2012-01-01 08:23:00 (CET, UTC+1); for Pacific/Tahiti to 2011-12-31 21:23:00 (UTC-10)
    self.date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:347095380.];
    
    // Date corresponding to March 1st on a leap year
    // For Europe/Zurich, this corresponds to 2012-03-01 06:12:00 (CET, UTC+1); for Pacific/Tahiti to 2012-02-29 19:12:00 (UTC-10)
    self.date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:352271520.];
    
    // The three dates below are used to test the CET -> CEST transition in the Europe/Zurich time zone
    
    // For Europe/Zurich, this corresponds to 2012-03-25 01:00:00 (CET, UTC+1); for Pacific/Tahiti to 2012-03-24 14:00:00 (UTC-10). This
    // is one hour before the transition occurs
    self.date3 = [NSDate dateWithTimeIntervalSinceReferenceDate:354326400.];
    
    // For Europe/Zurich, this corresponds to 2012-03-25 03:00:00 (CEST, UTC+2); for Pacific/Tahiti to 2012-03-24 15:00:00 (UTC-10). This
    // is the exact time at which the transition occurs (i.e. the first date in CEST)
    self.date4 = [NSDate dateWithTimeIntervalSinceReferenceDate:354330000.];
    
    // For Europe/Zurich, this corresponds to 2012-03-26 05:00:00 (CEST, UTC+2); for Pacific/Tahiti to 2012-03-25 17:00:00 (UTC-10). This
    // is about a day after the CET -> CEST transition has occurred
    self.date5 = [NSDate dateWithTimeIntervalSinceReferenceDate:354423600.];
}

#pragma mark Tests

- (void)testOffsetFromTimeZoneForDate
{
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date1], 11. * 60. * 60., nil);
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date2], 11. * 60. * 60., nil);
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date3], 11. * 60. * 60., nil);
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date4], 12. * 60. * 60., nil);
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date5], 12. * 60. * 60., nil);
}

- (void)testDateWithSameComponentsAsDatefromTimeZone
{
    // To compare components, we cannot use CoconutKit methods (since they are ulitmately implemented using the methods we
    // are testing!). We therefore use the system calendar and time zone here
    NSTimeZone *timeZone = [self.calendar timeZone];
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *dateFromZurich1 = [timeZone dateWithSameComponentsAsDate:self.date1 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich1 = [self.calendar components:unitFlags fromDate:dateFromZurich1];
    GHAssertEquals([dateComponentsFromZurich1 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromZurich1 month], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsFromZurich1 day], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsFromZurich1 hour], (NSInteger)8, nil);
    GHAssertEquals([dateComponentsFromZurich1 minute], (NSInteger)23, nil);
    
    NSDate *dateFromZurich2 = [timeZone dateWithSameComponentsAsDate:self.date2 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich2 = [self.calendar components:unitFlags fromDate:dateFromZurich2];
    GHAssertEquals([dateComponentsFromZurich2 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromZurich2 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsFromZurich2 day], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsFromZurich2 hour], (NSInteger)6, nil);
    GHAssertEquals([dateComponentsFromZurich2 minute], (NSInteger)12, nil);

    NSDate *dateFromZurich3 = [timeZone dateWithSameComponentsAsDate:self.date3 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich3 = [self.calendar components:unitFlags fromDate:dateFromZurich3];
    GHAssertEquals([dateComponentsFromZurich3 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromZurich3 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsFromZurich3 day], (NSInteger)25, nil);
    GHAssertEquals([dateComponentsFromZurich3 hour], (NSInteger)1, nil);
    
    NSDate *dateFromZurich4 = [timeZone dateWithSameComponentsAsDate:self.date4 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich4 = [self.calendar components:unitFlags fromDate:dateFromZurich4];
    GHAssertEquals([dateComponentsFromZurich4 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromZurich4 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsFromZurich4 day], (NSInteger)25, nil);
    GHAssertEquals([dateComponentsFromZurich4 hour], (NSInteger)3, nil);
    
    NSDate *dateFromZurich5 = [timeZone dateWithSameComponentsAsDate:self.date5 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich5 = [self.calendar components:unitFlags fromDate:dateFromZurich5];
    GHAssertEquals([dateComponentsFromZurich5 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromZurich5 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsFromZurich5 day], (NSInteger)26, nil);
    GHAssertEquals([dateComponentsFromZurich5 hour], (NSInteger)5, nil);
    
    NSDate *dateFromTahiti1 = [timeZone dateWithSameComponentsAsDate:self.date1 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti1 = [self.calendar components:unitFlags fromDate:dateFromTahiti1];
    GHAssertEquals([dateComponentsFromTahiti1 year], (NSInteger)2011, nil);
    GHAssertEquals([dateComponentsFromTahiti1 month], (NSInteger)12, nil);
    GHAssertEquals([dateComponentsFromTahiti1 day], (NSInteger)31, nil);
    GHAssertEquals([dateComponentsFromTahiti1 hour], (NSInteger)21, nil);
    GHAssertEquals([dateComponentsFromTahiti1 minute], (NSInteger)23, nil);
    
    NSDate *dateFromTahiti2 = [timeZone dateWithSameComponentsAsDate:self.date2 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti2 = [self.calendar components:unitFlags fromDate:dateFromTahiti2];
    GHAssertEquals([dateComponentsFromTahiti2 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromTahiti2 month], (NSInteger)2, nil);
    GHAssertEquals([dateComponentsFromTahiti2 day], (NSInteger)29, nil);
    GHAssertEquals([dateComponentsFromTahiti2 hour], (NSInteger)19, nil);
    GHAssertEquals([dateComponentsFromTahiti2 minute], (NSInteger)12, nil);
    
    NSDate *dateFromTahiti3 = [timeZone dateWithSameComponentsAsDate:self.date3 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti3 = [self.calendar components:unitFlags fromDate:dateFromTahiti3];
    GHAssertEquals([dateComponentsFromTahiti3 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromTahiti3 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsFromTahiti3 day], (NSInteger)24, nil);
    GHAssertEquals([dateComponentsFromTahiti3 hour], (NSInteger)14, nil);
    
    NSDate *dateFromTahiti4 = [timeZone dateWithSameComponentsAsDate:self.date4 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti4 = [self.calendar components:unitFlags fromDate:dateFromTahiti4];
    GHAssertEquals([dateComponentsFromTahiti4 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromTahiti4 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsFromTahiti4 day], (NSInteger)24, nil);
    GHAssertEquals([dateComponentsFromTahiti4 hour], (NSInteger)15, nil);
    
    NSDate *dateFromTahiti5 = [timeZone dateWithSameComponentsAsDate:self.date5 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti5 = [self.calendar components:unitFlags fromDate:dateFromTahiti5];
    GHAssertEquals([dateComponentsFromTahiti5 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsFromTahiti5 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsFromTahiti5 day], (NSInteger)25, nil);
    GHAssertEquals([dateComponentsFromTahiti5 hour], (NSInteger)17, nil);
}

- (void)testDateByAddingTimeIntervalToDate
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *dateZurich1 = [self.timeZoneZurich dateByAddingTimeInterval:10. * 60. * 60. toDate:self.date1];
    NSDateComponents *dateComponentsZurich1 = [self.calendar components:unitFlags fromDate:dateZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich1 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich1 month], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsZurich1 day], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsZurich1 hour], (NSInteger)18, nil);
    GHAssertEquals([dateComponentsZurich1 minute], (NSInteger)23, nil);
    
    NSDate *dateZurich2 = [self.timeZoneZurich dateByAddingTimeInterval:-4. * 60. * 60. toDate:self.date2];
    NSDateComponents *dateComponentsZurich2 = [self.calendar components:unitFlags fromDate:dateZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich2 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich2 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsZurich2 day], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsZurich2 hour], (NSInteger)2, nil);
    GHAssertEquals([dateComponentsZurich2 minute], (NSInteger)12, nil);
    
    NSDate *dateZurich3 = [self.timeZoneZurich dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date3];
    NSDateComponents *dateComponentsZurich3 = [self.calendar components:unitFlags fromDate:dateZurich3 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich3 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich3 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsZurich3 day], (NSInteger)25, nil);
    GHAssertEquals([dateComponentsZurich3 hour], (NSInteger)6, nil);
    
    NSDate *dateZurich4 = [self.timeZoneZurich dateByAddingTimeInterval:-2. * 60. * 60. toDate:self.date4];
    NSDateComponents *dateComponentsZurich4 = [self.calendar components:unitFlags fromDate:dateZurich4 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich4 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich4 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsZurich4 day], (NSInteger)25, nil);
    GHAssertEquals([dateComponentsZurich4 hour], (NSInteger)1, nil);
    
    NSDate *dateZurich5 = [self.timeZoneZurich dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date5];
    NSDateComponents *dateComponentsZurich5 = [self.calendar components:unitFlags fromDate:dateZurich5 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich5 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich5 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsZurich5 day], (NSInteger)26, nil);
    GHAssertEquals([dateComponentsZurich5 hour], (NSInteger)10, nil);
    
    NSDate *dateTahiti1 = [self.timeZoneTahiti dateByAddingTimeInterval:10. * 60. * 60. toDate:self.date1];
    NSDateComponents *dateComponentsTahiti1 = [self.calendar components:unitFlags fromDate:dateTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti1 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti1 month], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsTahiti1 day], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsTahiti1 hour], (NSInteger)7, nil);
    GHAssertEquals([dateComponentsTahiti1 minute], (NSInteger)23, nil);
    
    NSDate *dateTahiti2 = [self.timeZoneTahiti dateByAddingTimeInterval:-4. * 60. * 60. toDate:self.date2];
    NSDateComponents *dateComponentsTahiti2 = [self.calendar components:unitFlags fromDate:dateTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti2 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti2 month], (NSInteger)2, nil);
    GHAssertEquals([dateComponentsTahiti2 day], (NSInteger)29, nil);
    GHAssertEquals([dateComponentsTahiti2 hour], (NSInteger)15, nil);
    GHAssertEquals([dateComponentsTahiti2 minute], (NSInteger)12, nil);
    
    NSDate *dateTahiti3 = [self.timeZoneTahiti dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date3];
    NSDateComponents *dateComponentsTahiti3 = [self.calendar components:unitFlags fromDate:dateTahiti3 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti3 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti3 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsTahiti3 day], (NSInteger)24, nil);
    GHAssertEquals([dateComponentsTahiti3 hour], (NSInteger)19, nil);
    
    NSDate *dateTahiti4 = [self.timeZoneTahiti dateByAddingTimeInterval:-2. * 60. * 60. toDate:self.date4];
    NSDateComponents *dateComponentsTahiti4 = [self.calendar components:unitFlags fromDate:dateTahiti4 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti4 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti4 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsTahiti4 day], (NSInteger)24, nil);
    GHAssertEquals([dateComponentsTahiti4 hour], (NSInteger)13, nil);
    
    NSDate *dateTahiti5 = [self.timeZoneTahiti dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date5];
    NSDateComponents *dateComponentsTahiti5 = [self.calendar components:unitFlags fromDate:dateTahiti5 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti5 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti5 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsTahiti5 day], (NSInteger)25, nil);
    GHAssertEquals([dateComponentsTahiti5 hour], (NSInteger)22, nil);
}

- (void)testDateByAddingNumberOfDaysToDate
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *dateZurich1 = [self.timeZoneZurich dateByAddingNumberOfDays:5 toDate:self.date1];
    NSDateComponents *dateComponentsZurich1 = [self.calendar components:unitFlags fromDate:dateZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich1 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich1 month], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsZurich1 day], (NSInteger)6, nil);
    GHAssertEquals([dateComponentsZurich1 hour], (NSInteger)8, nil);
    GHAssertEquals([dateComponentsZurich1 minute], (NSInteger)23, nil);
    
    NSDate *dateZurich2 = [self.timeZoneZurich dateByAddingNumberOfDays:-3 toDate:self.date2];
    NSDateComponents *dateComponentsZurich2 = [self.calendar components:unitFlags fromDate:dateZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich2 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich2 month], (NSInteger)2, nil);
    GHAssertEquals([dateComponentsZurich2 day], (NSInteger)27, nil);
    GHAssertEquals([dateComponentsZurich2 hour], (NSInteger)6, nil);
    GHAssertEquals([dateComponentsZurich2 minute], (NSInteger)12, nil);
    
    NSDate *dateZurich3 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date3];
    NSDateComponents *dateComponentsZurich3 = [self.calendar components:unitFlags fromDate:dateZurich3 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich3 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich3 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsZurich3 day], (NSInteger)27, nil);
    GHAssertEquals([dateComponentsZurich3 hour], (NSInteger)1, nil);
    
    NSDate *dateZurich4 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date4];
    NSDateComponents *dateComponentsZurich4 = [self.calendar components:unitFlags fromDate:dateZurich4 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich4 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich4 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsZurich4 day], (NSInteger)27, nil);
    GHAssertEquals([dateComponentsZurich4 hour], (NSInteger)3, nil);
    
    NSDate *dateZurich5 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date5];
    NSDateComponents *dateComponentsZurich5 = [self.calendar components:unitFlags fromDate:dateZurich5 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich5 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsZurich5 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsZurich5 day], (NSInteger)28, nil);
    GHAssertEquals([dateComponentsZurich5 hour], (NSInteger)5, nil);
    
    NSDate *dateTahiti1 = [self.timeZoneTahiti dateByAddingNumberOfDays:5 toDate:self.date1];
    NSDateComponents *dateComponentsTahiti1 = [self.calendar components:unitFlags fromDate:dateTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti1 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti1 month], (NSInteger)1, nil);
    GHAssertEquals([dateComponentsTahiti1 day], (NSInteger)5, nil);
    GHAssertEquals([dateComponentsTahiti1 hour], (NSInteger)21, nil);
    GHAssertEquals([dateComponentsTahiti1 minute], (NSInteger)23, nil);
    
    NSDate *dateTahiti2 = [self.timeZoneTahiti dateByAddingNumberOfDays:-3 toDate:self.date2];
    NSDateComponents *dateComponentsTahiti2 = [self.calendar components:unitFlags fromDate:dateTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti2 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti2 month], (NSInteger)2, nil);
    GHAssertEquals([dateComponentsTahiti2 day], (NSInteger)26, nil);
    GHAssertEquals([dateComponentsTahiti2 hour], (NSInteger)19, nil);
    GHAssertEquals([dateComponentsTahiti2 minute], (NSInteger)12, nil);
    
    NSDate *dateTahiti3 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date3];
    NSDateComponents *dateComponentsTahiti3 = [self.calendar components:unitFlags fromDate:dateTahiti3 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti3 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti3 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsTahiti3 day], (NSInteger)26, nil);
    GHAssertEquals([dateComponentsTahiti3 hour], (NSInteger)14, nil);
    
    NSDate *dateTahiti4 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date4];
    NSDateComponents *dateComponentsTahiti4 = [self.calendar components:unitFlags fromDate:dateTahiti4 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti4 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti4 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsTahiti4 day], (NSInteger)26, nil);
    GHAssertEquals([dateComponentsTahiti4 hour], (NSInteger)15, nil);
    
    NSDate *dateTahiti5 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date5];
    NSDateComponents *dateComponentsTahiti5 = [self.calendar components:unitFlags fromDate:dateTahiti5 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti5 year], (NSInteger)2012, nil);
    GHAssertEquals([dateComponentsTahiti5 month], (NSInteger)3, nil);
    GHAssertEquals([dateComponentsTahiti5 day], (NSInteger)27, nil);
    GHAssertEquals([dateComponentsTahiti5 hour], (NSInteger)17, nil);
}

- (void)testTimeIntervalBetweenDateAndDate
{
    NSTimeInterval timeIntervalZurich43 = [self.timeZoneZurich timeIntervalBetweenDate:self.date4 andDate:self.date3];
    GHAssertEquals(timeIntervalZurich43, 2. * 60. * 60., nil);
    
    NSTimeInterval timeIntervalZurich53 = [self.timeZoneZurich timeIntervalBetweenDate:self.date5 andDate:self.date3];
    GHAssertEquals(timeIntervalZurich53, 28. * 60. * 60., nil);
    
    NSTimeInterval timeIntervalZurich54 = [self.timeZoneZurich timeIntervalBetweenDate:self.date5 andDate:self.date4];
    GHAssertEquals(timeIntervalZurich54, 26. * 60. * 60., nil);
    
    NSTimeInterval timeIntervalTahiti43 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date4 andDate:self.date3];
    GHAssertEquals(timeIntervalTahiti43, 1. * 60. * 60., nil);
    
    NSTimeInterval timeIntervalTahiti53 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date5 andDate:self.date3];
    GHAssertEquals(timeIntervalTahiti53, 27. * 60. * 60., nil);
    
    NSTimeInterval timeIntervalTahiti54 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date5 andDate:self.date4];
    GHAssertEquals(timeIntervalTahiti54, 26. * 60. * 60., nil);
}

@end
