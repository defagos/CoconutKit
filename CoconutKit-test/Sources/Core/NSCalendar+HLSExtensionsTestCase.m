//
//  NSCalendar+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 17.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSCalendar+HLSExtensionsTestCase.h"

@interface NSCalendar_HLSExtensionsTestCase ()

@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, retain) NSTimeZone *timeZoneZurich;
@property (nonatomic, retain) NSTimeZone *timeZoneTahiti;
@property (nonatomic, retain) NSDate *date1;
@property (nonatomic, retain) NSDate *date2;

@end

@implementation NSCalendar_HLSExtensionsTestCase

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.calendar = nil;
    self.date1 = nil;
    self.date2 = nil;
    self.timeZoneZurich = nil;
    self.timeZoneTahiti = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize calendar = m_calendar;

@synthesize timeZoneZurich = m_timeZoneZurich;

@synthesize timeZoneTahiti = m_timeZoneTahiti;

@synthesize date1 = m_date1;

@synthesize date2 = m_date2;

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    self.calendar = [NSCalendar currentCalendar];
    self.timeZoneZurich = [NSTimeZone timeZoneWithName:@"Europe/Zurich"];
    self.timeZoneTahiti = [NSTimeZone timeZoneWithName:@"Pacific/Tahiti"];           // Europe/Zurich - 12 hours
    
    // Pick two dates which correspond to two different days in the Zurich / Tahiti time zones
    
    // For Europe/Zurich, this corresponds to 2012-01-01 08:23:00; for Pacific/Tahiti, to 2011-12-31 20:23:00
    self.date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:347095380];
    
    // For Europe/Zurich, this corresponds to 2012-03-01 06:12:00; for Pacific/Tahiti, to 2012-02-29 18:12:00 (leap year)
    self.date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:352271520];
}

#pragma mark Tests

- (void)testDateFromComponentsInTimeZone
{
    NSDateComponents *dateComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [dateComponentsZurich1 setYear:2012];
    [dateComponentsZurich1 setMonth:1];
    [dateComponentsZurich1 setDay:1];
    [dateComponentsZurich1 setHour:8];
    [dateComponentsZurich1 setMinute:23];
    NSDate *dateZurich1 = [self.calendar dateFromComponents:dateComponentsZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich1 isEqualToDate:self.date1], @"Incorrect date");
    
    NSDateComponents *dateComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [dateComponentsZurich2 setYear:2012];
    [dateComponentsZurich2 setMonth:3];
    [dateComponentsZurich2 setDay:1];
    [dateComponentsZurich2 setHour:6];
    [dateComponentsZurich2 setMinute:12];
    NSDate *dateZurich2 = [self.calendar dateFromComponents:dateComponentsZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich2 isEqualToDate:self.date2], @"Incorrect date");
    
    NSDateComponents *dateComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [dateComponentsTahiti1 setYear:2011];
    [dateComponentsTahiti1 setMonth:12];
    [dateComponentsTahiti1 setDay:31];
    [dateComponentsTahiti1 setHour:20];
    [dateComponentsTahiti1 setMinute:23];
    NSDate *dateTahiti1 = [self.calendar dateFromComponents:dateComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti1 isEqualToDate:self.date1], @"Incorrect date");
    
    NSDateComponents *dateComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [dateComponentsTahiti2 setYear:2012];
    [dateComponentsTahiti2 setMonth:2];
    [dateComponentsTahiti2 setDay:29];
    [dateComponentsTahiti2 setHour:18];
    [dateComponentsTahiti2 setMinute:12];
    NSDate *dateTahiti2 = [self.calendar dateFromComponents:dateComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti2 isEqualToDate:self.date2], @"Incorrect date");
}

- (void)testComponentsFromDateInTimeZone
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *dateComponentsZurich1 = [self.calendar components:unitFlags fromDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich1 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich1 month], 1, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich1 day], 1, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich1 hour], 8, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich1 minute], 23, @"Incorrect minute");
    
    NSDateComponents *dateComponentsZurich2 = [self.calendar components:unitFlags fromDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich2 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich2 day], 1, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich2 hour], 6, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich2 minute], 12, @"Incorrect minute");

    NSDateComponents *dateComponentsTahiti1 = [self.calendar components:unitFlags fromDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti1 year], 2011, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti1 month], 12, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti1 day], 31, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti1 hour], 20, @"Incorrect hour");
    GHAssertEquals([dateComponentsTahiti1 minute], 23, @"Incorrect minute");
    
    NSDateComponents *dateComponentsTahiti2 = [self.calendar components:unitFlags fromDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti2 month], 2, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti2 day], 29, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti2 hour], 18, @"Incorrect hour");
    GHAssertEquals([dateComponentsTahiti2 minute], 12, @"Incorrect minute");
}

- (void)testNumberOfDaysInUnitContainingDateInTimeZone
{
    NSUInteger nbrDaysInMonthZurich1 = [self.calendar numberOfDaysInUnit:NSMonthCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(nbrDaysInMonthZurich1, 31U, @"Incorrect days in month");
    
    NSUInteger nbrDaysInYearZurich1 = [self.calendar numberOfDaysInUnit:NSYearCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(nbrDaysInYearZurich1, 366U, @"Incorrect days in year");
    
    NSUInteger nbrDaysInMonthZurich2 = [self.calendar numberOfDaysInUnit:NSMonthCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(nbrDaysInMonthZurich2, 31U, @"Incorrect days in month");
    
    NSUInteger nbrDaysInYearZurich2 = [self.calendar numberOfDaysInUnit:NSYearCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(nbrDaysInYearZurich2, 366U, @"Incorrect days in year");
    
    NSUInteger nbrDaysInMonthTahiti1 = [self.calendar numberOfDaysInUnit:NSMonthCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(nbrDaysInMonthTahiti1, 31U, @"Incorrect days in month");
    
    NSUInteger nbrDaysInYearTahiti1 = [self.calendar numberOfDaysInUnit:NSYearCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(nbrDaysInYearTahiti1, 365U, @"Incorrect days in year");
    
    NSUInteger nbrDaysInMonthTahiti2 = [self.calendar numberOfDaysInUnit:NSMonthCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(nbrDaysInMonthTahiti2, 29U, @"Incorrect days in month");
    
    NSUInteger nbrDaysInYearTahiti2 = [self.calendar numberOfDaysInUnit:NSYearCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(nbrDaysInYearTahiti2, 366U, @"Incorrect days in year");
}

- (void)testStartDateOfUnitContainingDateInTimeZone
{
    NSDate *startDateMonthZurich1 = [self.calendar startDateOfUnit:NSMonthCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedStartDateMonthComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateMonthComponentsZurich1 setYear:2012];
    [expectedStartDateMonthComponentsZurich1 setMonth:1];
    [expectedStartDateMonthComponentsZurich1 setDay:1];
    NSDate *expectedStartDateMonthZurich1 = [self.calendar dateFromComponents:expectedStartDateMonthComponentsZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([startDateMonthZurich1 isEqualToDate:expectedStartDateMonthZurich1], @"Incorrect date");
    
    NSDate *startDateYearZurich1 = [self.calendar startDateOfUnit:NSYearCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedStartDateYearComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateYearComponentsZurich1 setYear:2012];
    [expectedStartDateYearComponentsZurich1 setMonth:1];
    [expectedStartDateYearComponentsZurich1 setDay:1];
    NSDate *expectedStartDateYearZurich1 = [self.calendar dateFromComponents:expectedStartDateYearComponentsZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([startDateYearZurich1 isEqualToDate:expectedStartDateYearZurich1], @"Incorrect date");
    
    NSDate *startDateMonthZurich2 = [self.calendar startDateOfUnit:NSMonthCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedStartDateMonthComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateMonthComponentsZurich2 setYear:2012];
    [expectedStartDateMonthComponentsZurich2 setMonth:3];
    [expectedStartDateMonthComponentsZurich2 setDay:1];
    NSDate *expectedStartDateMonthZurich2 = [self.calendar dateFromComponents:expectedStartDateMonthComponentsZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([startDateMonthZurich2 isEqualToDate:expectedStartDateMonthZurich2], @"Incorrect date");
    
    NSDate *startDateYearZurich2 = [self.calendar startDateOfUnit:NSYearCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedStartDateYearComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateYearComponentsZurich2 setYear:2012];
    [expectedStartDateYearComponentsZurich2 setMonth:1];
    [expectedStartDateYearComponentsZurich2 setDay:1];
    NSDate *expectedStartDateYearZurich2 = [self.calendar dateFromComponents:expectedStartDateYearComponentsZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([startDateYearZurich2 isEqualToDate:expectedStartDateYearZurich2], @"Incorrect date");
    
    NSDate *startDateMonthTahiti1 = [self.calendar startDateOfUnit:NSMonthCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedStartDateMonthComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateMonthComponentsTahiti1 setYear:2011];
    [expectedStartDateMonthComponentsTahiti1 setMonth:12];
    [expectedStartDateMonthComponentsTahiti1 setDay:1];
    NSDate *expectedStartDateMonthTahiti1 = [self.calendar dateFromComponents:expectedStartDateMonthComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([startDateMonthTahiti1 isEqualToDate:expectedStartDateMonthTahiti1], @"Incorrect date");
    
    NSDate *startDateYearTahiti1 = [self.calendar startDateOfUnit:NSYearCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedStartDateYearComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateYearComponentsTahiti1 setYear:2011];
    [expectedStartDateYearComponentsTahiti1 setMonth:1];
    [expectedStartDateYearComponentsTahiti1 setDay:1];
    NSDate *expectedStartDateYearTahiti1 = [self.calendar dateFromComponents:expectedStartDateYearComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([startDateYearTahiti1 isEqualToDate:expectedStartDateYearTahiti1], @"Incorrect date");
    
    NSDate *startDateMonthTahiti2 = [self.calendar startDateOfUnit:NSMonthCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedStartDateMonthComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateMonthComponentsTahiti2 setYear:2012];
    [expectedStartDateMonthComponentsTahiti2 setMonth:2];
    [expectedStartDateMonthComponentsTahiti2 setDay:1];
    NSDate *expectedStartDateMonthTahiti2 = [self.calendar dateFromComponents:expectedStartDateMonthComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([startDateMonthTahiti2 isEqualToDate:expectedStartDateMonthTahiti2], @"Incorrect date");
    
    NSDate *startDateYearTahiti2 = [self.calendar startDateOfUnit:NSYearCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedStartDateYearComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedStartDateYearComponentsTahiti2 setYear:2012];
    [expectedStartDateYearComponentsTahiti2 setMonth:1];
    [expectedStartDateYearComponentsTahiti2 setDay:1];
    NSDate *expectedStartDateYearTahiti2 = [self.calendar dateFromComponents:expectedStartDateYearComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([startDateYearTahiti2 isEqualToDate:expectedStartDateYearTahiti2], @"Incorrect date");
}

- (void)testEndDateOfUnitContainingDateInTimeZone
{
    NSDate *endDateMonthZurich1 = [self.calendar endDateOfUnit:NSMonthCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedEndDateMonthComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateMonthComponentsZurich1 setYear:2012];
    [expectedEndDateMonthComponentsZurich1 setMonth:2];
    [expectedEndDateMonthComponentsZurich1 setDay:1];
    NSDate *expectedEndDateMonthZurich1 = [self.calendar dateFromComponents:expectedEndDateMonthComponentsZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([endDateMonthZurich1 isEqualToDate:expectedEndDateMonthZurich1], @"Incorrect date");
    
    NSDate *endDateYearZurich1 = [self.calendar endDateOfUnit:NSYearCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedEndDateYearComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateYearComponentsZurich1 setYear:2013];
    [expectedEndDateYearComponentsZurich1 setMonth:1];
    [expectedEndDateYearComponentsZurich1 setDay:1];
    NSDate *expectedEndDateYearZurich1 = [self.calendar dateFromComponents:expectedEndDateYearComponentsZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([endDateYearZurich1 isEqualToDate:expectedEndDateYearZurich1], @"Incorrect date");
    
    NSDate *endDateMonthZurich2 = [self.calendar endDateOfUnit:NSMonthCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedEndDateMonthComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateMonthComponentsZurich2 setYear:2012];
    [expectedEndDateMonthComponentsZurich2 setMonth:4];
    [expectedEndDateMonthComponentsZurich2 setDay:1];
    [expectedEndDateMonthComponentsZurich2 setHour:1];          // CEST, at +1 in April, not 0
    NSDate *expectedEndDateMonthZurich2 = [self.calendar dateFromComponents:expectedEndDateMonthComponentsZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([endDateMonthZurich2 isEqualToDate:expectedEndDateMonthZurich2], @"Incorrect date");
    
    NSDate *endDateYearZurich2 = [self.calendar endDateOfUnit:NSYearCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneZurich];
    NSDateComponents *expectedEndDateYearComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateYearComponentsZurich2 setYear:2013];
    [expectedEndDateYearComponentsZurich2 setMonth:1];
    [expectedEndDateYearComponentsZurich2 setDay:1];
    NSDate *expectedEndDateYearZurich2 = [self.calendar dateFromComponents:expectedEndDateYearComponentsZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([endDateYearZurich2 isEqualToDate:expectedEndDateYearZurich2], @"Incorrect date");
    
    NSDate *endDateMonthTahiti1 = [self.calendar endDateOfUnit:NSMonthCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedEndDateMonthComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateMonthComponentsTahiti1 setYear:2012];
    [expectedEndDateMonthComponentsTahiti1 setMonth:1];
    [expectedEndDateMonthComponentsTahiti1 setDay:1];
    NSDate *expectedEndDateMonthTahiti1 = [self.calendar dateFromComponents:expectedEndDateMonthComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([endDateMonthTahiti1 isEqualToDate:expectedEndDateMonthTahiti1], @"Incorrect date");
    
    NSDate *endDateYearTahiti1 = [self.calendar endDateOfUnit:NSYearCalendarUnit containingDate:self.date1 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedEndDateYearComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateYearComponentsTahiti1 setYear:2012];
    [expectedEndDateYearComponentsTahiti1 setMonth:1];
    [expectedEndDateYearComponentsTahiti1 setDay:1];
    NSDate *expectedEndDateYearTahiti1 = [self.calendar dateFromComponents:expectedEndDateYearComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([endDateYearTahiti1 isEqualToDate:expectedEndDateYearTahiti1], @"Incorrect date");
    
    NSDate *endDateMonthTahiti2 = [self.calendar endDateOfUnit:NSMonthCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedEndDateMonthComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateMonthComponentsTahiti2 setYear:2012];
    [expectedEndDateMonthComponentsTahiti2 setMonth:3];
    [expectedEndDateMonthComponentsTahiti2 setDay:1];
    NSDate *expectedEndDateMonthTahiti2 = [self.calendar dateFromComponents:expectedEndDateMonthComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([endDateMonthTahiti2 isEqualToDate:expectedEndDateMonthTahiti2], @"Incorrect date");
    
    NSDate *endDateYearTahiti2 = [self.calendar endDateOfUnit:NSYearCalendarUnit containingDate:self.date2 inTimeZone:self.timeZoneTahiti];
    NSDateComponents *expectedEndDateYearComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedEndDateYearComponentsTahiti2 setYear:2013];
    [expectedEndDateYearComponentsTahiti2 setMonth:1];
    [expectedEndDateYearComponentsTahiti2 setDay:1];
    NSDate *expectedEndDateYearTahiti2 = [self.calendar dateFromComponents:expectedEndDateYearComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([endDateYearTahiti2 isEqualToDate:expectedEndDateYearTahiti2], @"Incorrect date");
}

- (void)testRangeOfUnitInUnitForDateInTimeZone
{
    // Days in a year are always in [1; 31], whatever the date
    NSRange rangeDayInYearZurich1 = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue(NSEqualRanges(rangeDayInYearZurich1, NSMakeRange(1, 31)), @"Incorrect range");
    
    // Months in a year are always in [1; 12], whatever the date
    NSRange rangeMonthInYearZurich1 = [self.calendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue(NSEqualRanges(rangeMonthInYearZurich1, NSMakeRange(1, 12)), @"Incorrect range");
    
    // January 2012: 31 days
    NSRange rangeDayInMonthZurich1 = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue(NSEqualRanges(rangeDayInMonthZurich1, NSMakeRange(1, 31)), @"Incorrect range");
    
    // March 2012: 31 days
    NSRange rangeDayInMonthZurich2 = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertTrue(NSEqualRanges(rangeDayInMonthZurich2, NSMakeRange(1, 31)), @"Incorrect range");
    
    // December 2011: 31 days
    NSRange rangeDayInMonthTahiti1 = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue(NSEqualRanges(rangeDayInMonthTahiti1, NSMakeRange(1, 31)), @"Incorrect range");
    
    // February 2012: 29 days
    NSRange rangeDayInMonthTahiti2 = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue(NSEqualRanges(rangeDayInMonthTahiti2, NSMakeRange(1, 29)), @"Incorrect range");    
}

- (void)testOrdinalityOfUnitInUnitForDateInTimeZone
{
    NSUInteger ordinalityDayInYearZurich1 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(ordinalityDayInYearZurich1, 1U, @"Incorrect ordinality");
    
    NSUInteger ordinalityDayInYearZurich2 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(ordinalityDayInYearZurich2, 61U, @"Incorrect ordinality");
    
    NSUInteger ordinalityDayInYearTahiti1 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(ordinalityDayInYearTahiti1, 365U, @"Incorrect ordinality");
    
    NSUInteger ordinalityDayInYearTahiti2 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(ordinalityDayInYearTahiti2, 60U, @"Incorrect ordinality");
    
    NSUInteger ordinalityMonthInYearZurich1 = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(ordinalityMonthInYearZurich1, 1U, @"Incorrect ordinality");

    NSUInteger ordinalityMonthInYearZurich2 = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(ordinalityMonthInYearZurich2, 3U, @"Incorrect ordinality");

    NSUInteger ordinalityMonthInYearTahiti1 = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(ordinalityMonthInYearTahiti1, 12U, @"Incorrect ordinality");
    
    NSUInteger ordinalityMonthInYearTahiti2 = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(ordinalityMonthInYearTahiti2, 2U, @"Incorrect ordinality");
    
    NSUInteger ordinalityDayInMonthZurich1 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(ordinalityDayInMonthZurich1, 1U, @"Incorrect ordinality");
    
    NSUInteger ordinalityDayInMonthZurich2 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(ordinalityDayInMonthZurich2, 1U, @"Incorrect ordinality");
    
    NSUInteger ordinalityDayInMonthTahiti1 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(ordinalityDayInMonthTahiti1, 31U, @"Incorrect ordinality");
    
    NSUInteger ordinalityDayInMonthTahiti2 = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(ordinalityDayInMonthTahiti2, 29U, @"Incorrect ordinality");
}

- (void)testRangeOfUnitStartDateIntervalForDateInTimeZone
{
    // Just a wrapper around rangeOfUnit:startDate:interval:forDate:. It suffices to test whether one of the outputs is correct (interval is the easiest
    // one), the other (startDate, which is more cumbersome to test) will be correct as well
    NSTimeInterval intervalDayInMonthZurich1 = 0.;
    [self.calendar rangeOfUnit:NSMonthCalendarUnit startDate:NULL interval:&intervalDayInMonthZurich1 forDate:self.date1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(round(intervalDayInMonthZurich1 / (24 * 60 * 60)), 31.,        // January 2012: 31 days
                   @"Incorrect time interval");
    
    NSTimeInterval intervalDayInMonthZurich2 = 0.;
    [self.calendar rangeOfUnit:NSMonthCalendarUnit startDate:NULL interval:&intervalDayInMonthZurich2 forDate:self.date2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals(round(intervalDayInMonthZurich2 / (24 * 60 * 60)), 31.,        // March 2012: 31 days
                   @"Incorrect time interval");
    
    NSTimeInterval intervalDayInMonthTahiti1 = 0.;
    [self.calendar rangeOfUnit:NSMonthCalendarUnit startDate:NULL interval:&intervalDayInMonthTahiti1 forDate:self.date1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(round(intervalDayInMonthTahiti1 / (24 * 60 * 60)), 31.,        // December 2011: 31 days
                   @"Incorrect time interval");
    
    NSTimeInterval intervalDayInMonthTahiti2 = 0.;
    [self.calendar rangeOfUnit:NSMonthCalendarUnit startDate:NULL interval:&intervalDayInMonthTahiti2 forDate:self.date2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals(round(intervalDayInMonthTahiti2 / (24 * 60 * 60)), 29.,        // February 2012: 29 days
                   @"Incorrect time interval");
}

@end
