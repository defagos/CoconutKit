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
    
    
    
    // TODO: Update as for NSCalendar tests
    
    
    
    
    // Pick two dates which correspond to two different days in the Zurich / Tahiti time zones
    
    // For Europe/Zurich, this corresponds to 2012-01-01 08:23:00; for Pacific/Tahiti, to 2011-12-31 20:23:00
    self.date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:347095380.];
    
    // For Europe/Zurich, this corresponds to 2012-03-01 06:12:00; for Pacific/Tahiti, to 2012-02-29 18:12:00 (leap year)
    self.date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:352271520.];
    
    // TODO: Comment
    // date1 = 322880400 = 2012-04-27 03:00:00 (CEST +200)
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

- (void)testDateSameDayAtNoon
{
    NSDateComponents *expectedDateComponents1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponents1 setYear:2012];
    [expectedDateComponents1 setMonth:1];
    [expectedDateComponents1 setDay:1];
    [expectedDateComponents1 setHour:12];
    NSDate *expectedDate1 = [self.calendar dateFromComponents:expectedDateComponents1];
    NSDate *date1 = [self.date1 dateSameDayAtNoon];
    GHAssertTrue([date1 isEqualToDate:expectedDate1], @"Date");
    
    NSDateComponents *expectedDateComponents2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponents2 setYear:2012];
    [expectedDateComponents2 setMonth:3];
    [expectedDateComponents2 setDay:1];
    [expectedDateComponents2 setHour:12];
    NSDate *expectedDate2 = [self.calendar dateFromComponents:expectedDateComponents2];
    NSDate *date2 = [self.date2 dateSameDayAtNoon];
    GHAssertTrue([date2 isEqualToDate:expectedDate2], @"Date");
}

- (void)testDateSameDayAtNoonInTimeZone
{
    NSDateComponents *expectedDateComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsZurich1 setYear:2012];
    [expectedDateComponentsZurich1 setMonth:1];
    [expectedDateComponentsZurich1 setDay:1];
    [expectedDateComponentsZurich1 setHour:12];
    NSDate *expectedDateZurich1 = [self.calendar dateFromComponents:expectedDateComponentsZurich1 inTimeZone:self.timeZoneZurich];
    NSDate *dateZurich1 = [self.date1 dateSameDayAtNoonInTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich1 isEqualToDate:expectedDateZurich1], @"Date");
    
    NSDateComponents *expectedDateComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsZurich2 setYear:2012];
    [expectedDateComponentsZurich2 setMonth:3];
    [expectedDateComponentsZurich2 setDay:1];
    [expectedDateComponentsZurich2 setHour:12];
    NSDate *expectedDateZurich2 = [self.calendar dateFromComponents:expectedDateComponentsZurich2 inTimeZone:self.timeZoneZurich];
    NSDate *dateZurich2 = [self.date2 dateSameDayAtNoonInTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich2 isEqualToDate:expectedDateZurich2], @"Date");
    
    NSDateComponents *expectedDateComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsTahiti1 setYear:2011];
    [expectedDateComponentsTahiti1 setMonth:12];
    [expectedDateComponentsTahiti1 setDay:31];
    [expectedDateComponentsTahiti1 setHour:12];
    NSDate *expectedDateTahiti1 = [self.calendar dateFromComponents:expectedDateComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    NSDate *dateTahiti1 = [self.date1 dateSameDayAtNoonInTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti1 isEqualToDate:expectedDateTahiti1], @"Date");
    
    NSDateComponents *expectedDateComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsTahiti2 setYear:2012];
    [expectedDateComponentsTahiti2 setMonth:2];
    [expectedDateComponentsTahiti2 setDay:29];
    [expectedDateComponentsTahiti2 setHour:12];
    NSDate *expectedDateTahiti2 = [self.calendar dateFromComponents:expectedDateComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    NSDate *dateTahiti2 = [self.date2 dateSameDayAtNoonInTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti2 isEqualToDate:expectedDateTahiti2], @"Date");
}

- (void)testDateSameDayAtMidnight
{
    NSDateComponents *expectedDateComponents1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponents1 setYear:2012];
    [expectedDateComponents1 setMonth:1];
    [expectedDateComponents1 setDay:1];
    NSDate *expectedDate1 = [self.calendar dateFromComponents:expectedDateComponents1];
    NSDate *date1 = [self.date1 dateSameDayAtMidnight];
    GHAssertTrue([date1 isEqualToDate:expectedDate1], @"Date");
    
    NSDateComponents *expectedDateComponents2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponents2 setYear:2012];
    [expectedDateComponents2 setMonth:3];
    [expectedDateComponents2 setDay:1];
    NSDate *expectedDate2 = [self.calendar dateFromComponents:expectedDateComponents2];
    NSDate *date2 = [self.date2 dateSameDayAtMidnight];
    GHAssertTrue([date2 isEqualToDate:expectedDate2], @"Date");
}

- (void)testDateSameDayAtMidnightInTimeZone
{
    NSDateComponents *expectedDateComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsZurich1 setYear:2012];
    [expectedDateComponentsZurich1 setMonth:1];
    [expectedDateComponentsZurich1 setDay:1];
    NSDate *expectedDateZurich1 = [self.calendar dateFromComponents:expectedDateComponentsZurich1 inTimeZone:self.timeZoneZurich];
    NSDate *dateZurich1 = [self.date1 dateSameDayAtMidnightInTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich1 isEqualToDate:expectedDateZurich1], @"Date");
    
    NSDateComponents *expectedDateComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsZurich2 setYear:2012];
    [expectedDateComponentsZurich2 setMonth:3];
    [expectedDateComponentsZurich2 setDay:1];
    NSDate *expectedDateZurich2 = [self.calendar dateFromComponents:expectedDateComponentsZurich2 inTimeZone:self.timeZoneZurich];
    NSDate *dateZurich2 = [self.date2 dateSameDayAtMidnightInTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich2 isEqualToDate:expectedDateZurich2], @"Date");
    
    NSDateComponents *expectedDateComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsTahiti1 setYear:2011];
    [expectedDateComponentsTahiti1 setMonth:12];
    [expectedDateComponentsTahiti1 setDay:31];
    NSDate *expectedDateTahiti1 = [self.calendar dateFromComponents:expectedDateComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    NSDate *dateTahiti1 = [self.date1 dateSameDayAtMidnightInTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti1 isEqualToDate:expectedDateTahiti1], @"Date");
    
    NSDateComponents *expectedDateComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsTahiti2 setYear:2012];
    [expectedDateComponentsTahiti2 setMonth:2];
    [expectedDateComponentsTahiti2 setDay:29];
    NSDate *expectedDateTahiti2 = [self.calendar dateFromComponents:expectedDateComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    NSDate *dateTahiti2 = [self.date2 dateSameDayAtMidnightInTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti2 isEqualToDate:expectedDateTahiti2], @"Date");
}

- (void)testDateSameDayAtHourMinuteSecond
{
    NSDateComponents *expectedDateComponents1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponents1 setYear:2012];
    [expectedDateComponents1 setMonth:1];
    [expectedDateComponents1 setDay:1];
    [expectedDateComponents1 setHour:14];
    [expectedDateComponents1 setMinute:27];
    [expectedDateComponents1 setSecond:36];
    NSDate *expectedDate1 = [self.calendar dateFromComponents:expectedDateComponents1];
    NSDate *date1 = [self.date1 dateSameDayAtHour:14 minute:27 second:36];
    GHAssertTrue([date1 isEqualToDate:expectedDate1], @"Date");
    
    NSDateComponents *expectedDateComponents2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponents2 setYear:2012];
    [expectedDateComponents2 setMonth:3];
    [expectedDateComponents2 setDay:1];
    [expectedDateComponents2 setHour:14];
    [expectedDateComponents2 setMinute:27];
    [expectedDateComponents2 setSecond:36];
    NSDate *expectedDate2 = [self.calendar dateFromComponents:expectedDateComponents2];
    NSDate *date2 = [self.date2 dateSameDayAtHour:14 minute:27 second:36];
    GHAssertTrue([date2 isEqualToDate:expectedDate2], @"Date");
}

- (void)testDateSameDayAtHourMinuteSecondInTimeZone
{
    NSDateComponents *expectedDateComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsZurich1 setYear:2012];
    [expectedDateComponentsZurich1 setMonth:1];
    [expectedDateComponentsZurich1 setDay:1];
    [expectedDateComponentsZurich1 setHour:14];
    [expectedDateComponentsZurich1 setMinute:27];
    [expectedDateComponentsZurich1 setSecond:36];
    NSDate *expectedDateZurich1 = [self.calendar dateFromComponents:expectedDateComponentsZurich1 inTimeZone:self.timeZoneZurich];
    NSDate *dateZurich1 = [self.date1 dateSameDayAtHour:14 minute:27 second:36 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich1 isEqualToDate:expectedDateZurich1], @"Date");
    
    NSDateComponents *expectedDateComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsZurich2 setYear:2012];
    [expectedDateComponentsZurich2 setMonth:3];
    [expectedDateComponentsZurich2 setDay:1];
    [expectedDateComponentsZurich2 setHour:14];
    [expectedDateComponentsZurich2 setMinute:27];
    [expectedDateComponentsZurich2 setSecond:36];
    NSDate *expectedDateZurich2 = [self.calendar dateFromComponents:expectedDateComponentsZurich2 inTimeZone:self.timeZoneZurich];
    NSDate *dateZurich2 = [self.date2 dateSameDayAtHour:14 minute:27 second:36 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([dateZurich2 isEqualToDate:expectedDateZurich2], @"Date");
    
    NSDateComponents *expectedDateComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsTahiti1 setYear:2011];
    [expectedDateComponentsTahiti1 setMonth:12];
    [expectedDateComponentsTahiti1 setDay:31];
    [expectedDateComponentsTahiti1 setHour:14];
    [expectedDateComponentsTahiti1 setMinute:27];
    [expectedDateComponentsTahiti1 setSecond:36];
    NSDate *expectedDateTahiti1 = [self.calendar dateFromComponents:expectedDateComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    NSDate *dateTahiti1 = [self.date1 dateSameDayAtHour:14 minute:27 second:36 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti1 isEqualToDate:expectedDateTahiti1], @"Date");
    
    NSDateComponents *expectedDateComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [expectedDateComponentsTahiti2 setYear:2012];
    [expectedDateComponentsTahiti2 setMonth:2];
    [expectedDateComponentsTahiti2 setDay:29];
    [expectedDateComponentsTahiti2 setHour:14];
    [expectedDateComponentsTahiti2 setMinute:27];
    [expectedDateComponentsTahiti2 setSecond:36];
    NSDate *expectedDateTahiti2 = [self.calendar dateFromComponents:expectedDateComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    NSDate *dateTahiti2 = [self.date2 dateSameDayAtHour:14 minute:27 second:36 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([dateTahiti2 isEqualToDate:expectedDateTahiti2], @"Date");
}

- (void)testCompareDayWithDate
{
    NSDateComponents *otherDateComponents1 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponents1 setYear:2012];
    [otherDateComponents1 setMonth:1];
    [otherDateComponents1 setDay:1];
    [otherDateComponents1 setHour:15];
    NSDate *otherDate1 = [self.calendar dateFromComponents:otherDateComponents1];
    GHAssertTrue([self.date1 compareDayWithDate:otherDate1] == NSOrderedSame, @"Day");
    
    NSDateComponents *otherDateComponents2 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponents2 setYear:2012];
    [otherDateComponents2 setMonth:3];
    [otherDateComponents2 setDay:1];
    [otherDateComponents2 setHour:15];
    NSDate *otherDate2 = [self.calendar dateFromComponents:otherDateComponents2];
    GHAssertTrue([self.date2 compareDayWithDate:otherDate2] == NSOrderedSame, @"Day");
}

- (void)testCompareDayWithDateInTimeZone
{
    NSDateComponents *otherDateComponentsZurich1 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponentsZurich1 setYear:2012];
    [otherDateComponentsZurich1 setMonth:1];
    [otherDateComponentsZurich1 setDay:1];
    [otherDateComponentsZurich1 setHour:15];
    NSDate *otherDateZurich1 = [self.calendar dateFromComponents:otherDateComponentsZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([self.date1 compareDayWithDate:otherDateZurich1] == NSOrderedSame, @"Day");
    
    NSDateComponents *otherDateComponentsZurich2 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponentsZurich2 setYear:2012];
    [otherDateComponentsZurich2 setMonth:3];
    [otherDateComponentsZurich2 setDay:1];
    [otherDateComponentsZurich2 setHour:15];
    NSDate *otherDateZurich2 = [self.calendar dateFromComponents:otherDateComponentsZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertTrue([self.date2 compareDayWithDate:otherDateZurich2] == NSOrderedSame, @"Day");
    
    NSDateComponents *otherDateComponentsTahiti1 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponentsTahiti1 setYear:2011];
    [otherDateComponentsTahiti1 setMonth:12];
    [otherDateComponentsTahiti1 setDay:31];
    [otherDateComponentsTahiti1 setHour:15];
    NSDate *otherDateTahiti1 = [self.calendar dateFromComponents:otherDateComponentsTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([self.date1 compareDayWithDate:otherDateTahiti1] == NSOrderedSame, @"Day");

    NSDateComponents *otherDateComponentsTahiti2 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponentsTahiti2 setYear:2012];
    [otherDateComponentsTahiti2 setMonth:2];
    [otherDateComponentsTahiti2 setDay:29];
    [otherDateComponentsTahiti2 setHour:15];
    NSDate *otherDateTahiti2 = [self.calendar dateFromComponents:otherDateComponentsTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertTrue([self.date2 compareDayWithDate:otherDateTahiti2] == NSOrderedSame, @"Day");
}

- (void)testDateByAddingNumberOfDays
{
#if 0
    NSDateComponents *otherDateComponents1 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponents1 setYear:2012];
    [otherDateComponents1 setMonth:1];
    [otherDateComponents1 setDay:21];
    [otherDateComponents1 setHour:8];
    [otherDateComponents1 setMinute:23];
    NSDate *otherDate1 = [self.calendar dateFromComponents:otherDateComponents1 inTimeZone:self.timeZoneZurich];
    NSDate *date1 = [self.date1 dateByAddingNumberOfDays:20];
    GHAssertTrue([date1 isEqualToDate:otherDate1], @"Add");    
    
    NSDateComponents *otherDateComponents2 = [[[NSDateComponents alloc] init] autorelease];
    [otherDateComponents2 setYear:2012];
    [otherDateComponents2 setMonth:2];
    [otherDateComponents2 setDay:19];
    [otherDateComponents2 setHour:18];
    [otherDateComponents2 setMinute:12];
    NSDate *otherDate2 = [self.calendar dateFromComponents:otherDateComponents2 inTimeZone:self.timeZoneTahiti];
    NSDate *date2 = [self.date2 dateByAddingNumberOfDays:-10];
    GHAssertTrue([date2 isEqualToDate:otherDate2], @"Add");
#endif
}

@end
