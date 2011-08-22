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
    
    // Pick two dates which correspond to two different days in the Zurich / Tahiti time zones
    
    // For Europe/Zurich, this corresponds to 2012-01-01 08:23:00; for Pacific/Tahiti, to 2011-12-31 20:23:00
    self.date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:347095380];
    
    // For Europe/Zurich, this corresponds to 2012-03-01 06:12:00; for Pacific/Tahiti, to 2012-02-29 18:12:00 (leap year)
    self.date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:352271520];
}

#pragma mark Tests

- (void)testDateSameDayAtNoon
{
    
}

- (void)testDateSameDayAtNoonInTimeZone
{

}

- (void)testDateSameDayAtMidnight
{

}

- (void)testDateSameDayAtMidnightInTimeZone
{

}

- (void)testDateSameDayAtHourMinuteSecond
{

}

- (void)testDateSameDayAtHourMinuteSecondInTimeZone
{

}

- (void)testCompareDayWithDate
{

}

- (void)testCompareDayWithDateInTimeZone
{

}

- (void)testIsSameDayAsDate
{

}

- (void)testIsSameDayAsDateInTimeZone
{

}

- (void)testDateByAddingNumberOfDays
{

}

@end
