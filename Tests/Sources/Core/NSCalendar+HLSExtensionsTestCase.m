//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import CoconutKit;
@import XCTest;

@interface NSCalendar_HLSExtensionsTestCase : XCTestCase

@property (nonatomic) NSCalendar *calendarZurich;
@property (nonatomic) NSCalendar *calendarTahiti;
@property (nonatomic) NSDate *date1;
@property (nonatomic) NSDate *date2;
@property (nonatomic) NSDate *date3;
@property (nonatomic) NSDate *date4;
@property (nonatomic) NSDate *date5;

@end

@implementation NSCalendar_HLSExtensionsTestCase

#pragma mark Test setup and tear down

- (void)setUp
{
    [super setUp];
    
    // Europe/Zurich uses CEST during summer, between 1:00 UTC on the last Sunday of March and until 1:00 on the last Sunday of October. 
    // CET is used for the rest of the year. Pacific/Tahiti does not use daylight saving times. In summary:
    //   - when Europe/Zurich uses CET (UTC+1): Zurich is 11 hours ahead of Tahiti (UTC-10)
    //   - when Europe/Zurich uses CEST (UTC+2): Zurich is 12 hours ahead of Tahiti (UTC-10)
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

- (void)testNumberOfDaysInUnitContainingDate
{
    NSUInteger nbrDaysInMonthZurich1 = [self.calendarZurich numberOfDaysInUnit:NSCalendarUnitMonth containingDate:self.date1];
    XCTAssertEqual(nbrDaysInMonthZurich1, (NSUInteger)31);
    
    NSUInteger nbrDaysInYearZurich1 = [self.calendarZurich numberOfDaysInUnit:NSCalendarUnitYear containingDate:self.date1];
    XCTAssertEqual(nbrDaysInYearZurich1, (NSUInteger)366);
    
    NSUInteger nbrDaysInMonthZurich2 = [self.calendarZurich numberOfDaysInUnit:NSCalendarUnitMonth containingDate:self.date2];
    XCTAssertEqual(nbrDaysInMonthZurich2, (NSUInteger)31);
    
    NSUInteger nbrDaysInYearZurich2 = [self.calendarZurich numberOfDaysInUnit:NSCalendarUnitYear containingDate:self.date2];
    XCTAssertEqual(nbrDaysInYearZurich2, (NSUInteger)366);
    
    NSUInteger nbrDaysInMonthTahiti1 = [self.calendarTahiti numberOfDaysInUnit:NSCalendarUnitMonth containingDate:self.date1];
    XCTAssertEqual(nbrDaysInMonthTahiti1, (NSUInteger)31);
    
    NSUInteger nbrDaysInYearTahiti1 = [self.calendarTahiti numberOfDaysInUnit:NSCalendarUnitYear containingDate:self.date1];
    XCTAssertEqual(nbrDaysInYearTahiti1, (NSUInteger)365);
    
    NSUInteger nbrDaysInMonthTahiti2 = [self.calendarTahiti numberOfDaysInUnit:NSCalendarUnitMonth containingDate:self.date2];
    XCTAssertEqual(nbrDaysInMonthTahiti2, (NSUInteger)29);
    
    NSUInteger nbrDaysInYearTahiti2 = [self.calendarTahiti numberOfDaysInUnit:NSCalendarUnitYear containingDate:self.date2];
    XCTAssertEqual(nbrDaysInYearTahiti2, (NSUInteger)366);
}

- (void)testStartDateOfUnitContainingDate
{
    NSDate *startDateMonthZurich1 = [self.calendarZurich startDateOfUnit:NSCalendarUnitMonth containingDate:self.date1];
    NSDateComponents *expectedStartDateMonthComponentsZurich1 = [[NSDateComponents alloc] init];
    expectedStartDateMonthComponentsZurich1.year = 2012;
    expectedStartDateMonthComponentsZurich1.month = 1;
    expectedStartDateMonthComponentsZurich1.day = 1;
    NSDate *expectedStartDateMonthZurich1 = [self.calendarZurich dateFromComponents:expectedStartDateMonthComponentsZurich1];
    XCTAssertTrue([startDateMonthZurich1 isEqualToDate:expectedStartDateMonthZurich1]);
    
    NSDate *startDateYearZurich1 = [self.calendarZurich startDateOfUnit:NSCalendarUnitYear containingDate:self.date1];
    NSDateComponents *expectedStartDateYearComponentsZurich1 = [[NSDateComponents alloc] init];
    expectedStartDateYearComponentsZurich1.year = 2012;
    expectedStartDateYearComponentsZurich1.month = 1;
    expectedStartDateYearComponentsZurich1.day = 1;
    NSDate *expectedStartDateYearZurich1 = [self.calendarZurich dateFromComponents:expectedStartDateYearComponentsZurich1];
    XCTAssertTrue([startDateYearZurich1 isEqualToDate:expectedStartDateYearZurich1]);
    
    NSDate *startDateMonthZurich2 = [self.calendarZurich startDateOfUnit:NSCalendarUnitMonth containingDate:self.date2];
    NSDateComponents *expectedStartDateMonthComponentsZurich2 = [[NSDateComponents alloc] init];
    expectedStartDateMonthComponentsZurich2.year = 2012;
    expectedStartDateMonthComponentsZurich2.month = 3;
    expectedStartDateMonthComponentsZurich2.day = 1;
    NSDate *expectedStartDateMonthZurich2 = [self.calendarZurich dateFromComponents:expectedStartDateMonthComponentsZurich2];
    XCTAssertTrue([startDateMonthZurich2 isEqualToDate:expectedStartDateMonthZurich2]);
    
    NSDate *startDateYearZurich2 = [self.calendarZurich startDateOfUnit:NSCalendarUnitYear containingDate:self.date2];
    NSDateComponents *expectedStartDateYearComponentsZurich2 = [[NSDateComponents alloc] init];
    expectedStartDateYearComponentsZurich2.year = 2012;
    expectedStartDateYearComponentsZurich2.month = 1;
    expectedStartDateYearComponentsZurich2.day = 1;
    NSDate *expectedStartDateYearZurich2 = [self.calendarZurich dateFromComponents:expectedStartDateYearComponentsZurich2];
    XCTAssertTrue([startDateYearZurich2 isEqualToDate:expectedStartDateYearZurich2]);
    
    NSDate *startDateMonthTahiti1 = [self.calendarTahiti startDateOfUnit:NSCalendarUnitMonth containingDate:self.date1];
    NSDateComponents *expectedStartDateMonthComponentsTahiti1 = [[NSDateComponents alloc] init];
    expectedStartDateMonthComponentsTahiti1.year = 2011;
    expectedStartDateMonthComponentsTahiti1.month = 12;
    expectedStartDateMonthComponentsTahiti1.day = 1;
    NSDate *expectedStartDateMonthTahiti1 = [self.calendarTahiti dateFromComponents:expectedStartDateMonthComponentsTahiti1];
    XCTAssertTrue([startDateMonthTahiti1 isEqualToDate:expectedStartDateMonthTahiti1]);
    
    NSDate *startDateYearTahiti1 = [self.calendarTahiti startDateOfUnit:NSCalendarUnitYear containingDate:self.date1];
    NSDateComponents *expectedStartDateYearComponentsTahiti1 = [[NSDateComponents alloc] init];
    expectedStartDateYearComponentsTahiti1.year = 2011;
    expectedStartDateYearComponentsTahiti1.month = 1;
    expectedStartDateYearComponentsTahiti1.day = 1;
    NSDate *expectedStartDateYearTahiti1 = [self.calendarTahiti dateFromComponents:expectedStartDateYearComponentsTahiti1];
    XCTAssertTrue([startDateYearTahiti1 isEqualToDate:expectedStartDateYearTahiti1]);
    
    NSDate *startDateMonthTahiti2 = [self.calendarTahiti startDateOfUnit:NSCalendarUnitMonth containingDate:self.date2];
    NSDateComponents *expectedStartDateMonthComponentsTahiti2 = [[NSDateComponents alloc] init];
    expectedStartDateMonthComponentsTahiti2.year = 2012;
    expectedStartDateMonthComponentsTahiti2.month = 2;
    expectedStartDateMonthComponentsTahiti2.day = 1;
    NSDate *expectedStartDateMonthTahiti2 = [self.calendarTahiti dateFromComponents:expectedStartDateMonthComponentsTahiti2];
    XCTAssertTrue([startDateMonthTahiti2 isEqualToDate:expectedStartDateMonthTahiti2]);
    
    NSDate *startDateYearTahiti2 = [self.calendarTahiti startDateOfUnit:NSCalendarUnitYear containingDate:self.date2];
    NSDateComponents *expectedStartDateYearComponentsTahiti2 = [[NSDateComponents alloc] init];
    expectedStartDateYearComponentsTahiti2.year = 2012;
    expectedStartDateYearComponentsTahiti2.month = 1;
    expectedStartDateYearComponentsTahiti2.day = 1;
    NSDate *expectedStartDateYearTahiti2 = [self.calendarTahiti dateFromComponents:expectedStartDateYearComponentsTahiti2];
    XCTAssertTrue([startDateYearTahiti2 isEqualToDate:expectedStartDateYearTahiti2]);
}

- (void)testEndDateOfUnitContainingDate
{
    NSDate *endDateMonthZurich1 = [self.calendarZurich endDateOfUnit:NSCalendarUnitMonth containingDate:self.date1];
    NSDateComponents *expectedEndDateMonthComponentsZurich1 = [[NSDateComponents alloc] init];
    expectedEndDateMonthComponentsZurich1.year = 2012;
    expectedEndDateMonthComponentsZurich1.month = 2;
    expectedEndDateMonthComponentsZurich1.day = 1;
    NSDate *expectedEndDateMonthZurich1 = [self.calendarZurich dateFromComponents:expectedEndDateMonthComponentsZurich1];
    XCTAssertTrue([endDateMonthZurich1 isEqualToDate:expectedEndDateMonthZurich1]);
    
    NSDate *endDateYearZurich1 = [self.calendarZurich endDateOfUnit:NSCalendarUnitYear containingDate:self.date1];
    NSDateComponents *expectedEndDateYearComponentsZurich1 = [[NSDateComponents alloc] init];
    expectedEndDateYearComponentsZurich1.year = 2013;
    expectedEndDateYearComponentsZurich1.month = 1;
    expectedEndDateYearComponentsZurich1.day = 1;
    NSDate *expectedEndDateYearZurich1 = [self.calendarZurich dateFromComponents:expectedEndDateYearComponentsZurich1];
    XCTAssertTrue([endDateYearZurich1 isEqualToDate:expectedEndDateYearZurich1]);
    
    NSDate *endDateMonthZurich2 = [self.calendarZurich endDateOfUnit:NSCalendarUnitMonth containingDate:self.date2];
    NSDateComponents *expectedEndDateMonthComponentsZurich2 = [[NSDateComponents alloc] init];
    expectedEndDateMonthComponentsZurich2.year = 2012;
    expectedEndDateMonthComponentsZurich2.month = 4;
    expectedEndDateMonthComponentsZurich2.day = 1;
    NSDate *expectedEndDateMonthZurich2 = [self.calendarZurich dateFromComponents:expectedEndDateMonthComponentsZurich2];
    XCTAssertTrue([endDateMonthZurich2 isEqualToDate:expectedEndDateMonthZurich2]);
    
    NSDate *endDateYearZurich2 = [self.calendarZurich endDateOfUnit:NSCalendarUnitYear containingDate:self.date2];
    NSDateComponents *expectedEndDateYearComponentsZurich2 = [[NSDateComponents alloc] init];
    expectedEndDateYearComponentsZurich2.year = 2013;
    expectedEndDateYearComponentsZurich2.month = 1;
    expectedEndDateYearComponentsZurich2.day = 1;
    NSDate *expectedEndDateYearZurich2 = [self.calendarZurich dateFromComponents:expectedEndDateYearComponentsZurich2];
    XCTAssertTrue([endDateYearZurich2 isEqualToDate:expectedEndDateYearZurich2]);
    
    NSDate *endDateMonthTahiti1 = [self.calendarTahiti endDateOfUnit:NSCalendarUnitMonth containingDate:self.date1];
    NSDateComponents *expectedEndDateMonthComponentsTahiti1 = [[NSDateComponents alloc] init];
    expectedEndDateMonthComponentsTahiti1.year = 2012;
    expectedEndDateMonthComponentsTahiti1.month = 1;
    expectedEndDateMonthComponentsTahiti1.day = 1;
    NSDate *expectedEndDateMonthTahiti1 = [self.calendarTahiti dateFromComponents:expectedEndDateMonthComponentsTahiti1];
    XCTAssertTrue([endDateMonthTahiti1 isEqualToDate:expectedEndDateMonthTahiti1]);
    
    NSDate *endDateYearTahiti1 = [self.calendarTahiti endDateOfUnit:NSCalendarUnitYear containingDate:self.date1];
    NSDateComponents *expectedEndDateYearComponentsTahiti1 = [[NSDateComponents alloc] init];
    expectedEndDateYearComponentsTahiti1.year = 2012;
    expectedEndDateYearComponentsTahiti1.month = 1;
    expectedEndDateYearComponentsTahiti1.day = 1;
    NSDate *expectedEndDateYearTahiti1 = [self.calendarTahiti dateFromComponents:expectedEndDateYearComponentsTahiti1];
    XCTAssertTrue([endDateYearTahiti1 isEqualToDate:expectedEndDateYearTahiti1]);
    
    NSDate *endDateMonthTahiti2 = [self.calendarTahiti endDateOfUnit:NSCalendarUnitMonth containingDate:self.date2];
    NSDateComponents *expectedEndDateMonthComponentsTahiti2 = [[NSDateComponents alloc] init];
    expectedEndDateMonthComponentsTahiti2.year = 2012;
    expectedEndDateMonthComponentsTahiti2.month = 3;
    expectedEndDateMonthComponentsTahiti2.day = 1;
    NSDate *expectedEndDateMonthTahiti2 = [self.calendarTahiti dateFromComponents:expectedEndDateMonthComponentsTahiti2];
    XCTAssertTrue([endDateMonthTahiti2 isEqualToDate:expectedEndDateMonthTahiti2]);
    
    NSDate *endDateYearTahiti2 = [self.calendarTahiti endDateOfUnit:NSCalendarUnitYear containingDate:self.date2];
    NSDateComponents *expectedEndDateYearComponentsTahiti2 = [[NSDateComponents alloc] init];
    expectedEndDateYearComponentsTahiti2.year = 2013;
    expectedEndDateYearComponentsTahiti2.month = 1;
    expectedEndDateYearComponentsTahiti2.day = 1;
    NSDate *expectedEndDateYearTahiti2 = [self.calendarTahiti dateFromComponents:expectedEndDateYearComponentsTahiti2];
    XCTAssertTrue([endDateYearTahiti2 isEqualToDate:expectedEndDateYearTahiti2]);
}

- (void)testDateAtNoonTheSameDayAsDate
{
    NSDateComponents *expectedDateComponentsZurich1 = [[NSDateComponents alloc] init];
    expectedDateComponentsZurich1.year = 2012;
    expectedDateComponentsZurich1.month = 1;
    expectedDateComponentsZurich1.day = 1;
    expectedDateComponentsZurich1.hour = 12;
    NSDate *expectedDateZurich1 = [self.calendarZurich dateFromComponents:expectedDateComponentsZurich1];
    NSDate *dateZurich1 = [self.calendarZurich dateAtNoonTheSameDayAsDate:self.date1];
    XCTAssertTrue([dateZurich1 isEqualToDate:expectedDateZurich1]);
    
    NSDateComponents *expectedDateComponentsZurich2 = [[NSDateComponents alloc] init];
    expectedDateComponentsZurich2.year = 2012;
    expectedDateComponentsZurich2.month = 3;
    expectedDateComponentsZurich2.day = 1;
    expectedDateComponentsZurich2.hour = 12;
    NSDate *expectedDateZurich2 = [self.calendarZurich dateFromComponents:expectedDateComponentsZurich2];
    NSDate *dateZurich2 = [self.calendarZurich dateAtNoonTheSameDayAsDate:self.date2];
    XCTAssertTrue([dateZurich2 isEqualToDate:expectedDateZurich2]);
    
    NSDateComponents *expectedDateComponentsTahiti1 = [[NSDateComponents alloc] init];
    expectedDateComponentsTahiti1.year = 2011;
    expectedDateComponentsTahiti1.month = 12;
    expectedDateComponentsTahiti1.day = 31;
    expectedDateComponentsTahiti1.hour = 12;
    NSDate *expectedDateTahiti1 = [self.calendarTahiti dateFromComponents:expectedDateComponentsTahiti1];
    NSDate *dateTahiti1 = [self.calendarTahiti dateAtNoonTheSameDayAsDate:self.date1];
    XCTAssertTrue([dateTahiti1 isEqualToDate:expectedDateTahiti1]);
    
    NSDateComponents *expectedDateComponentsTahiti2 = [[NSDateComponents alloc] init];
    expectedDateComponentsTahiti2.year = 2012;
    expectedDateComponentsTahiti2.month = 2;
    expectedDateComponentsTahiti2.day = 29;
    expectedDateComponentsTahiti2.hour = 12;
    NSDate *expectedDateTahiti2 = [self.calendarTahiti dateFromComponents:expectedDateComponentsTahiti2];
    NSDate *dateTahiti2 = [self.calendarTahiti dateAtNoonTheSameDayAsDate:self.date2];
    XCTAssertTrue([dateTahiti2 isEqualToDate:expectedDateTahiti2]);
}

- (void)testDateAtMidnightTheSameDayAsDate
{
    NSDateComponents *expectedDateComponentsZurich1 = [[NSDateComponents alloc] init];
    expectedDateComponentsZurich1.year = 2012;
    expectedDateComponentsZurich1.month = 1;
    expectedDateComponentsZurich1.day = 1;
    NSDate *expectedDateZurich1 = [self.calendarZurich dateFromComponents:expectedDateComponentsZurich1];
    NSDate *dateZurich1 = [self.calendarZurich dateAtMidnightTheSameDayAsDate:self.date1];
    XCTAssertTrue([dateZurich1 isEqualToDate:expectedDateZurich1]);
    
    NSDateComponents *expectedDateComponentsZurich2 = [[NSDateComponents alloc] init];
    expectedDateComponentsZurich2.year = 2012;
    expectedDateComponentsZurich2.month = 3;
    expectedDateComponentsZurich2.day = 1;
    NSDate *expectedDateZurich2 = [self.calendarZurich dateFromComponents:expectedDateComponentsZurich2];
    NSDate *dateZurich2 = [self.calendarZurich dateAtMidnightTheSameDayAsDate:self.date2];
    XCTAssertTrue([dateZurich2 isEqualToDate:expectedDateZurich2]);
    
    NSDateComponents *expectedDateComponentsTahiti1 = [[NSDateComponents alloc] init];
    expectedDateComponentsTahiti1.year = 2011;
    expectedDateComponentsTahiti1.month = 12;
    expectedDateComponentsTahiti1.day = 31;
    NSDate *expectedDateTahiti1 = [self.calendarTahiti dateFromComponents:expectedDateComponentsTahiti1];
    NSDate *dateTahiti1 = [self.calendarTahiti dateAtMidnightTheSameDayAsDate:self.date1];
    XCTAssertTrue([dateTahiti1 isEqualToDate:expectedDateTahiti1]);
    
    NSDateComponents *expectedDateComponentsTahiti2 = [[NSDateComponents alloc] init];
    expectedDateComponentsTahiti2.year = 2012;
    expectedDateComponentsTahiti2.month = 2;
    expectedDateComponentsTahiti2.day = 29;
    NSDate *expectedDateTahiti2 = [self.calendarTahiti dateFromComponents:expectedDateComponentsTahiti2];
    NSDate *dateTahiti2 = [self.calendarTahiti dateAtMidnightTheSameDayAsDate:self.date2];
    XCTAssertTrue([dateTahiti2 isEqualToDate:expectedDateTahiti2]);
}

- (void)testDateAtHourMinuteSecondTheSameDayAsDate
{
    NSDateComponents *expectedDateComponentsZurich1 = [[NSDateComponents alloc] init];
    expectedDateComponentsZurich1.year = 2012;
    expectedDateComponentsZurich1.month = 1;
    expectedDateComponentsZurich1.day = 1;
    expectedDateComponentsZurich1.hour = 14;
    expectedDateComponentsZurich1.minute = 27;
    expectedDateComponentsZurich1.second = 36;
    NSDate *expectedDateZurich1 = [self.calendarZurich dateFromComponents:expectedDateComponentsZurich1];
    NSDate *dateZurich1 = [self.calendarZurich dateAtHour:14 minute:27 second:36 theSameDayAsDate:self.date1];
    XCTAssertTrue([dateZurich1 isEqualToDate:expectedDateZurich1]);
    
    NSDateComponents *expectedDateComponentsZurich2 = [[NSDateComponents alloc] init];
    expectedDateComponentsZurich2.year = 2012;
    expectedDateComponentsZurich2.month = 3;
    expectedDateComponentsZurich2.day = 1;
    expectedDateComponentsZurich2.hour = 14;
    expectedDateComponentsZurich2.minute = 27;
    expectedDateComponentsZurich2.second = 36;
    NSDate *expectedDateZurich2 = [self.calendarZurich dateFromComponents:expectedDateComponentsZurich2];
    NSDate *dateZurich2 = [self.calendarZurich dateAtHour:14 minute:27 second:36 theSameDayAsDate:self.date2];
    XCTAssertTrue([dateZurich2 isEqualToDate:expectedDateZurich2]);
    
    NSDateComponents *expectedDateComponentsTahiti1 = [[NSDateComponents alloc] init];
    expectedDateComponentsTahiti1.year = 2011;
    expectedDateComponentsTahiti1.month = 12;
    expectedDateComponentsTahiti1.day = 31;
    expectedDateComponentsTahiti1.hour = 14;
    expectedDateComponentsTahiti1.minute = 27;
    expectedDateComponentsTahiti1.second = 36;
    NSDate *expectedDateTahiti1 = [self.calendarTahiti dateFromComponents:expectedDateComponentsTahiti1];
    NSDate *dateTahiti1 = [self.calendarTahiti dateAtHour:14 minute:27 second:36 theSameDayAsDate:self.date1];
    XCTAssertTrue([dateTahiti1 isEqualToDate:expectedDateTahiti1]);
    
    NSDateComponents *expectedDateComponentsTahiti2 = [[NSDateComponents alloc] init];
    expectedDateComponentsTahiti2.year = 2012;
    expectedDateComponentsTahiti2.month = 2;
    expectedDateComponentsTahiti2.day = 29;
    expectedDateComponentsTahiti2.hour = 14;
    expectedDateComponentsTahiti2.minute = 27;
    expectedDateComponentsTahiti2.second = 36;
    NSDate *expectedDateTahiti2 = [self.calendarTahiti dateFromComponents:expectedDateComponentsTahiti2];
    NSDate *dateTahiti2 = [self.calendarTahiti dateAtHour:14 minute:27 second:36 theSameDayAsDate:self.date2];
    XCTAssertTrue([dateTahiti2 isEqualToDate:expectedDateTahiti2]);
}

- (void)testCompareDaysBetweenDateAndDate
{
    NSDateComponents *otherDateComponentsZurich1 = [[NSDateComponents alloc] init];
    otherDateComponentsZurich1.year = 2012;
    otherDateComponentsZurich1.month = 1;
    otherDateComponentsZurich1.day = 1;
    otherDateComponentsZurich1.hour = 15;
    NSDate *otherDateZurich1 = [self.calendarZurich dateFromComponents:otherDateComponentsZurich1];
    XCTAssertTrue([self.calendarZurich compareDaysBetweenDate:self.date1 andDate:otherDateZurich1] == NSOrderedSame);
    
    NSDateComponents *otherDateComponentsZurich2 = [[NSDateComponents alloc] init];
    otherDateComponentsZurich2.year = 2012;
    otherDateComponentsZurich2.month = 3;
    otherDateComponentsZurich2.day = 1;
    otherDateComponentsZurich2.hour = 15;
    NSDate *otherDateZurich2 = [self.calendarZurich dateFromComponents:otherDateComponentsZurich2];
    XCTAssertTrue([self.calendarZurich compareDaysBetweenDate:self.date2 andDate:otherDateZurich2] == NSOrderedSame);
    
    NSDateComponents *otherDateComponentsTahiti1 = [[NSDateComponents alloc] init];
    otherDateComponentsTahiti1.year = 2011;
    otherDateComponentsTahiti1.month = 12;
    otherDateComponentsTahiti1.day = 31;
    otherDateComponentsTahiti1.hour = 15;
    NSDate *otherDateTahiti1 = [self.calendarTahiti dateFromComponents:otherDateComponentsTahiti1];
    XCTAssertTrue([self.calendarTahiti compareDaysBetweenDate:self.date1 andDate:otherDateTahiti1] == NSOrderedSame);
    
    NSDateComponents *otherDateComponentsTahiti2 = [[NSDateComponents alloc] init];
    otherDateComponentsTahiti2.year = 2012;
    otherDateComponentsTahiti2.month = 2;
    otherDateComponentsTahiti2.day = 29;
    otherDateComponentsTahiti2.hour = 15;
    NSDate *otherDateTahiti2 = [self.calendarTahiti dateFromComponents:otherDateComponentsTahiti2];
    XCTAssertTrue([self.calendarTahiti compareDaysBetweenDate:self.date2 andDate:otherDateTahiti2] == NSOrderedSame);
}

@end
