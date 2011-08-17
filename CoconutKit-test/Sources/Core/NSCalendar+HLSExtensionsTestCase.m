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

}

- (void)testEndDateOfUnitContainingDateInTimeZone
{
    
}

- (void)testRangeOfUnitInUnitForDateInTimeZone
{

}

- (void)testOrdinalityOfUnitInUnitForDateInTimeZone
{

}

- (void)testRangeOfUnitStartDateIntervalForDateInTimeZone
{

}

@end
