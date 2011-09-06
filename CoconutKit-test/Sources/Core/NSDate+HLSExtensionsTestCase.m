//
//  NSDate+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 17.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensionsTestCase.h"

@interface NSDate_HLSExtensionsTestCase ()

@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, retain) NSTimeZone *timeZoneZurich;
@property (nonatomic, retain) NSTimeZone *timeZoneTahiti;
@property (nonatomic, retain) NSDate *date1;
@property (nonatomic, retain) NSDate *date2;
@property (nonatomic, retain) NSDate *date3;
@property (nonatomic, retain) NSDate *date4;
@property (nonatomic, retain) NSDate *date5;

@end

@implementation NSDate_HLSExtensionsTestCase

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.calendar = nil;
    self.timeZoneZurich = nil;
    self.timeZoneTahiti = nil;
    self.date1 = nil;
    self.date2 = nil;
    self.date3 = nil;
    self.date4 = nil;
    self.date5 = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize calendar = m_calendar;

@synthesize timeZoneZurich = m_timeZoneZurich;

@synthesize timeZoneTahiti = m_timeZoneTahiti;

@synthesize date1 = m_date1;

@synthesize date2 = m_date2;

@synthesize date3 = m_date3;

@synthesize date4 = m_date4;

@synthesize date5 = m_date5;

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

- (void)testDateComparisons
{
    NSDate *date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:100000.];
    NSDate *date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:100001.];
    
    GHAssertTrue([date1 isEarlierThanDate:date2], @"Earlier date");
    
    GHAssertTrue([date1 isEarlierThanOrEqualToDate:date2], @"Earlier or equal date");
    GHAssertTrue([date1 isEarlierThanOrEqualToDate:date1], @"Earlier or equal date");
    
    GHAssertTrue([date2 isLaterThanDate:date1], @"Later date");
    
    GHAssertTrue([date1 isLaterThanOrEqualToDate:date1], @"Later date");
    GHAssertTrue([date1 isLaterThanOrEqualToDate:date1], @"Later date");
}

- (void)testdateWithSameTimeComponentsByAddingNumberOfDaysToDate
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *dateZurich1 = [self.date1 dateWithSameTimeComponentsByAddingNumberOfDays:5 inTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsZurich1 = [self.calendar components:unitFlags fromDate:dateZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich1 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich1 month], 1, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich1 day], 6, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich1 hour], 8, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich1 minute], 23, @"Incorrect minute");
    
    NSDate *dateZurich2 = [self.date2 dateWithSameTimeComponentsByAddingNumberOfDays:-3 inTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsZurich2 = [self.calendar components:unitFlags fromDate:dateZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich2 month], 2, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich2 day], 27, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich2 hour], 6, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich2 minute], 12, @"Incorrect minute");
    
    NSDate *dateZurich3 = [self.date3 dateWithSameTimeComponentsByAddingNumberOfDays:2 inTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsZurich3 = [self.calendar components:unitFlags fromDate:dateZurich3 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich3 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich3 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich3 day], 27, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich3 hour], 1, @"Incorrect hour");
    
    NSDate *dateZurich4 = [self.date4 dateWithSameTimeComponentsByAddingNumberOfDays:2 inTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsZurich4 = [self.calendar components:unitFlags fromDate:dateZurich4 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich4 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich4 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich4 day], 27, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich4 hour], 3, @"Incorrect hour");
    
    NSDate *dateZurich5 = [self.date5 dateWithSameTimeComponentsByAddingNumberOfDays:2 inTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsZurich5 = [self.calendar components:unitFlags fromDate:dateZurich5 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich5 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich5 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich5 day], 28, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich5 hour], 5, @"Incorrect hour");
}

@end
