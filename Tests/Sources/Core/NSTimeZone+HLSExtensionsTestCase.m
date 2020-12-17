//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import CoconutKit;
@import XCTest;

@interface NSTimeZone_HLSExtensionsTestCase : XCTestCase

@property (nonatomic) NSTimeZone *timeZoneZurich;
@property (nonatomic) NSTimeZone *timeZoneTahiti;

@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSCalendar *calendarZurich;
@property (nonatomic) NSCalendar *calendarTahiti;

@property (nonatomic) NSDate *date1;
@property (nonatomic) NSDate *date2;
@property (nonatomic) NSDate *date3;
@property (nonatomic) NSDate *date4;
@property (nonatomic) NSDate *date5;

@end

@implementation NSTimeZone_HLSExtensionsTestCase

#pragma mark Test setup and tear down

- (void)setUp
{
    [super setUp];
    
    // Europe/Zurich uses CEST during summer, between 1:00 UTC on the last Sunday of March and until 1:00 on the last Sunday of October. 
    // CET is used for the rest of the year. Pacific/Tahiti does not use daylight saving times. In summary:
    //   - when Europe/Zurich uses CET (UTC+1): Zurich is 11 hours ahead of Tahiti (UTC-10)
    //   - when Europe/Zurich uses CEST (UTC+2): Zurich is 12 hours ahead of Tahiti (UTC-10)
    self.timeZoneZurich = [NSTimeZone timeZoneWithName:@"Europe/Zurich"];
    self.timeZoneTahiti = [NSTimeZone timeZoneWithName:@"Pacific/Tahiti"];
    
    self.calendar = [NSCalendar currentCalendar];
    
    self.calendarZurich = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.calendarZurich.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Zurich"];
    
    self.calendarTahiti = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.calendarTahiti.timeZone = [NSTimeZone timeZoneWithName:@"Pacific/Tahiti"];
    
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
    XCTAssertEqual([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date1], 11. * 60. * 60.);
    XCTAssertEqual([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date2], 11. * 60. * 60.);
    XCTAssertEqual([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date3], 11. * 60. * 60.);
    XCTAssertEqual([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date4], 12. * 60. * 60.);
    XCTAssertEqual([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date5], 12. * 60. * 60.);
}

- (void)testDateWithSameComponentsAsDatefromTimeZone
{
    // To compare components, we cannot use CoconutKit methods (since they are ulitmately implemented using the methods we
    // are testing!). We therefore use the system calendar and time zone here
    NSTimeZone *timeZone = self.calendar.timeZone;
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDate *dateFromZurich1 = [timeZone dateWithSameComponentsAsDate:self.date1 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich1 = [self.calendar components:unitFlags fromDate:dateFromZurich1];
    XCTAssertEqual(dateComponentsFromZurich1.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromZurich1.month, (NSInteger)1);
    XCTAssertEqual(dateComponentsFromZurich1.day, (NSInteger)1);
    XCTAssertEqual(dateComponentsFromZurich1.hour, (NSInteger)8);
    XCTAssertEqual(dateComponentsFromZurich1.minute, (NSInteger)23);
    
    NSDate *dateFromZurich2 = [timeZone dateWithSameComponentsAsDate:self.date2 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich2 = [self.calendar components:unitFlags fromDate:dateFromZurich2];
    XCTAssertEqual(dateComponentsFromZurich2.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromZurich2.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsFromZurich2.day, (NSInteger)1);
    XCTAssertEqual(dateComponentsFromZurich2.hour, (NSInteger)6);
    XCTAssertEqual(dateComponentsFromZurich2.minute, (NSInteger)12);

    NSDate *dateFromZurich3 = [timeZone dateWithSameComponentsAsDate:self.date3 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich3 = [self.calendar components:unitFlags fromDate:dateFromZurich3];
    XCTAssertEqual(dateComponentsFromZurich3.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromZurich3.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsFromZurich3.day, (NSInteger)25);
    XCTAssertEqual(dateComponentsFromZurich3.hour, (NSInteger)1);
    
    NSDate *dateFromZurich4 = [timeZone dateWithSameComponentsAsDate:self.date4 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich4 = [self.calendar components:unitFlags fromDate:dateFromZurich4];
    XCTAssertEqual(dateComponentsFromZurich4.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromZurich4.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsFromZurich4.day, (NSInteger)25);
    XCTAssertEqual(dateComponentsFromZurich4.hour, (NSInteger)3);
    
    NSDate *dateFromZurich5 = [timeZone dateWithSameComponentsAsDate:self.date5 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich5 = [self.calendar components:unitFlags fromDate:dateFromZurich5];
    XCTAssertEqual(dateComponentsFromZurich5.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromZurich5.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsFromZurich5.day, (NSInteger)26);
    XCTAssertEqual(dateComponentsFromZurich5.hour, (NSInteger)5);
    
    NSDate *dateFromTahiti1 = [timeZone dateWithSameComponentsAsDate:self.date1 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti1 = [self.calendar components:unitFlags fromDate:dateFromTahiti1];
    XCTAssertEqual(dateComponentsFromTahiti1.year, (NSInteger)2011);
    XCTAssertEqual(dateComponentsFromTahiti1.month, (NSInteger)12);
    XCTAssertEqual(dateComponentsFromTahiti1.day, (NSInteger)31);
    XCTAssertEqual(dateComponentsFromTahiti1.hour, (NSInteger)21);
    XCTAssertEqual(dateComponentsFromTahiti1.minute, (NSInteger)23);
    
    NSDate *dateFromTahiti2 = [timeZone dateWithSameComponentsAsDate:self.date2 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti2 = [self.calendar components:unitFlags fromDate:dateFromTahiti2];
    XCTAssertEqual(dateComponentsFromTahiti2.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromTahiti2.month, (NSInteger)2);
    XCTAssertEqual(dateComponentsFromTahiti2.day, (NSInteger)29);
    XCTAssertEqual(dateComponentsFromTahiti2.hour, (NSInteger)19);
    XCTAssertEqual(dateComponentsFromTahiti2.minute, (NSInteger)12);
    
    NSDate *dateFromTahiti3 = [timeZone dateWithSameComponentsAsDate:self.date3 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti3 = [self.calendar components:unitFlags fromDate:dateFromTahiti3];
    XCTAssertEqual(dateComponentsFromTahiti3.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromTahiti3.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsFromTahiti3.day, (NSInteger)24);
    XCTAssertEqual(dateComponentsFromTahiti3.hour, (NSInteger)14);
    
    NSDate *dateFromTahiti4 = [timeZone dateWithSameComponentsAsDate:self.date4 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti4 = [self.calendar components:unitFlags fromDate:dateFromTahiti4];
    XCTAssertEqual(dateComponentsFromTahiti4.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromTahiti4.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsFromTahiti4.day, (NSInteger)24);
    XCTAssertEqual(dateComponentsFromTahiti4.hour, (NSInteger)15);
    
    NSDate *dateFromTahiti5 = [timeZone dateWithSameComponentsAsDate:self.date5 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti5 = [self.calendar components:unitFlags fromDate:dateFromTahiti5];
    XCTAssertEqual(dateComponentsFromTahiti5.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsFromTahiti5.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsFromTahiti5.day, (NSInteger)25);
    XCTAssertEqual(dateComponentsFromTahiti5.hour, (NSInteger)17);
}

- (void)testDateByAddingTimeIntervalToDate
{
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDate *dateZurich1 = [self.timeZoneZurich dateByAddingTimeInterval:10. * 60. * 60. toDate:self.date1];
    NSDateComponents *dateComponentsZurich1 = [self.calendarZurich components:unitFlags fromDate:dateZurich1];
    XCTAssertEqual(dateComponentsZurich1.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich1.month, (NSInteger)1);
    XCTAssertEqual(dateComponentsZurich1.day, (NSInteger)1);
    XCTAssertEqual(dateComponentsZurich1.hour, (NSInteger)18);
    XCTAssertEqual(dateComponentsZurich1.minute, (NSInteger)23);
    
    NSDate *dateZurich2 = [self.timeZoneZurich dateByAddingTimeInterval:-4. * 60. * 60. toDate:self.date2];
    NSDateComponents *dateComponentsZurich2 = [self.calendarZurich components:unitFlags fromDate:dateZurich2];
    XCTAssertEqual(dateComponentsZurich2.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich2.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsZurich2.day, (NSInteger)1);
    XCTAssertEqual(dateComponentsZurich2.hour, (NSInteger)2);
    XCTAssertEqual(dateComponentsZurich2.minute, (NSInteger)12);
    
    NSDate *dateZurich3 = [self.timeZoneZurich dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date3];
    NSDateComponents *dateComponentsZurich3 = [self.calendarZurich components:unitFlags fromDate:dateZurich3];
    XCTAssertEqual(dateComponentsZurich3.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich3.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsZurich3.day, (NSInteger)25);
    XCTAssertEqual(dateComponentsZurich3.hour, (NSInteger)6);
    
    NSDate *dateZurich4 = [self.timeZoneZurich dateByAddingTimeInterval:-2. * 60. * 60. toDate:self.date4];
    NSDateComponents *dateComponentsZurich4 = [self.calendarZurich components:unitFlags fromDate:dateZurich4];
    XCTAssertEqual(dateComponentsZurich4.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich4.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsZurich4.day, (NSInteger)25);
    XCTAssertEqual(dateComponentsZurich4.hour, (NSInteger)1);
    
    NSDate *dateZurich5 = [self.timeZoneZurich dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date5];
    NSDateComponents *dateComponentsZurich5 = [self.calendarZurich components:unitFlags fromDate:dateZurich5];
    XCTAssertEqual(dateComponentsZurich5.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich5.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsZurich5.day, (NSInteger)26);
    XCTAssertEqual(dateComponentsZurich5.hour, (NSInteger)10);
    
    NSDate *dateTahiti1 = [self.timeZoneTahiti dateByAddingTimeInterval:10. * 60. * 60. toDate:self.date1];
    NSDateComponents *dateComponentsTahiti1 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti1];
    XCTAssertEqual(dateComponentsTahiti1.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti1.month, (NSInteger)1);
    XCTAssertEqual(dateComponentsTahiti1.day, (NSInteger)1);
    XCTAssertEqual(dateComponentsTahiti1.hour, (NSInteger)7);
    XCTAssertEqual(dateComponentsTahiti1.minute, (NSInteger)23);
    
    NSDate *dateTahiti2 = [self.timeZoneTahiti dateByAddingTimeInterval:-4. * 60. * 60. toDate:self.date2];
    NSDateComponents *dateComponentsTahiti2 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti2];
    XCTAssertEqual(dateComponentsTahiti2.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti2.month, (NSInteger)2);
    XCTAssertEqual(dateComponentsTahiti2.day, (NSInteger)29);
    XCTAssertEqual(dateComponentsTahiti2.hour, (NSInteger)15);
    XCTAssertEqual(dateComponentsTahiti2.minute, (NSInteger)12);
    
    NSDate *dateTahiti3 = [self.timeZoneTahiti dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date3];
    NSDateComponents *dateComponentsTahiti3 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti3];
    XCTAssertEqual(dateComponentsTahiti3.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti3.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsTahiti3.day, (NSInteger)24);
    XCTAssertEqual(dateComponentsTahiti3.hour, (NSInteger)19);
    
    NSDate *dateTahiti4 = [self.timeZoneTahiti dateByAddingTimeInterval:-2. * 60. * 60. toDate:self.date4];
    NSDateComponents *dateComponentsTahiti4 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti4];
    XCTAssertEqual(dateComponentsTahiti4.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti4.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsTahiti4.day, (NSInteger)24);
    XCTAssertEqual(dateComponentsTahiti4.hour, (NSInteger)13);
    
    NSDate *dateTahiti5 = [self.timeZoneTahiti dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date5];
    NSDateComponents *dateComponentsTahiti5 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti5];
    XCTAssertEqual(dateComponentsTahiti5.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti5.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsTahiti5.day, (NSInteger)25);
    XCTAssertEqual(dateComponentsTahiti5.hour, (NSInteger)22);
}

- (void)testDateByAddingNumberOfDaysToDate
{
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDate *dateZurich1 = [self.timeZoneZurich dateByAddingNumberOfDays:5 toDate:self.date1];
    NSDateComponents *dateComponentsZurich1 = [self.calendarZurich components:unitFlags fromDate:dateZurich1];
    XCTAssertEqual(dateComponentsZurich1.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich1.month, (NSInteger)1);
    XCTAssertEqual(dateComponentsZurich1.day, (NSInteger)6);
    XCTAssertEqual(dateComponentsZurich1.hour, (NSInteger)8);
    XCTAssertEqual(dateComponentsZurich1.minute, (NSInteger)23);
    
    NSDate *dateZurich2 = [self.timeZoneZurich dateByAddingNumberOfDays:-3 toDate:self.date2];
    NSDateComponents *dateComponentsZurich2 = [self.calendarZurich components:unitFlags fromDate:dateZurich2];
    XCTAssertEqual(dateComponentsZurich2.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich2.month, (NSInteger)2);
    XCTAssertEqual(dateComponentsZurich2.day, (NSInteger)27);
    XCTAssertEqual(dateComponentsZurich2.hour, (NSInteger)6);
    XCTAssertEqual(dateComponentsZurich2.minute, (NSInteger)12);
    
    NSDate *dateZurich3 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date3];
    NSDateComponents *dateComponentsZurich3 = [self.calendarZurich components:unitFlags fromDate:dateZurich3];
    XCTAssertEqual(dateComponentsZurich3.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich3.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsZurich3.day, (NSInteger)27);
    XCTAssertEqual(dateComponentsZurich3.hour, (NSInteger)1);
    
    NSDate *dateZurich4 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date4];
    NSDateComponents *dateComponentsZurich4 = [self.calendarZurich components:unitFlags fromDate:dateZurich4];
    XCTAssertEqual(dateComponentsZurich4.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich4.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsZurich4.day, (NSInteger)27);
    XCTAssertEqual(dateComponentsZurich4.hour, (NSInteger)3);
    
    NSDate *dateZurich5 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date5];
    NSDateComponents *dateComponentsZurich5 = [self.calendarZurich components:unitFlags fromDate:dateZurich5];
    XCTAssertEqual(dateComponentsZurich5.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsZurich5.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsZurich5.day, (NSInteger)28);
    XCTAssertEqual(dateComponentsZurich5.hour, (NSInteger)5);
    
    NSDate *dateTahiti1 = [self.timeZoneTahiti dateByAddingNumberOfDays:5 toDate:self.date1];
    NSDateComponents *dateComponentsTahiti1 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti1];
    XCTAssertEqual(dateComponentsTahiti1.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti1.month, (NSInteger)1);
    XCTAssertEqual(dateComponentsTahiti1.day, (NSInteger)5);
    XCTAssertEqual(dateComponentsTahiti1.hour, (NSInteger)21);
    XCTAssertEqual(dateComponentsTahiti1.minute, (NSInteger)23);
    
    NSDate *dateTahiti2 = [self.timeZoneTahiti dateByAddingNumberOfDays:-3 toDate:self.date2];
    NSDateComponents *dateComponentsTahiti2 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti2];
    XCTAssertEqual(dateComponentsTahiti2.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti2.month, (NSInteger)2);
    XCTAssertEqual(dateComponentsTahiti2.day, (NSInteger)26);
    XCTAssertEqual(dateComponentsTahiti2.hour, (NSInteger)19);
    XCTAssertEqual(dateComponentsTahiti2.minute, (NSInteger)12);
    
    NSDate *dateTahiti3 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date3];
    NSDateComponents *dateComponentsTahiti3 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti3];
    XCTAssertEqual(dateComponentsTahiti3.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti3.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsTahiti3.day, (NSInteger)26);
    XCTAssertEqual(dateComponentsTahiti3.hour, (NSInteger)14);
    
    NSDate *dateTahiti4 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date4];
    NSDateComponents *dateComponentsTahiti4 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti4];
    XCTAssertEqual(dateComponentsTahiti4.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti4.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsTahiti4.day, (NSInteger)26);
    XCTAssertEqual(dateComponentsTahiti4.hour, (NSInteger)15);
    
    NSDate *dateTahiti5 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date5];
    NSDateComponents *dateComponentsTahiti5 = [self.calendarTahiti components:unitFlags fromDate:dateTahiti5];
    XCTAssertEqual(dateComponentsTahiti5.year, (NSInteger)2012);
    XCTAssertEqual(dateComponentsTahiti5.month, (NSInteger)3);
    XCTAssertEqual(dateComponentsTahiti5.day, (NSInteger)27);
    XCTAssertEqual(dateComponentsTahiti5.hour, (NSInteger)17);
}

- (void)testTimeIntervalBetweenDateAndDate
{
    NSTimeInterval timeIntervalZurich43 = [self.timeZoneZurich timeIntervalBetweenDate:self.date4 andDate:self.date3];
    XCTAssertEqual(timeIntervalZurich43, 2. * 60. * 60.);
    
    NSTimeInterval timeIntervalZurich53 = [self.timeZoneZurich timeIntervalBetweenDate:self.date5 andDate:self.date3];
    XCTAssertEqual(timeIntervalZurich53, 28. * 60. * 60.);
    
    NSTimeInterval timeIntervalZurich54 = [self.timeZoneZurich timeIntervalBetweenDate:self.date5 andDate:self.date4];
    XCTAssertEqual(timeIntervalZurich54, 26. * 60. * 60.);
    
    NSTimeInterval timeIntervalTahiti43 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date4 andDate:self.date3];
    XCTAssertEqual(timeIntervalTahiti43, 1. * 60. * 60.);
    
    NSTimeInterval timeIntervalTahiti53 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date5 andDate:self.date3];
    XCTAssertEqual(timeIntervalTahiti53, 27. * 60. * 60.);
    
    NSTimeInterval timeIntervalTahiti54 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date5 andDate:self.date4];
    XCTAssertEqual(timeIntervalTahiti54, 26. * 60. * 60.);
}

@end
