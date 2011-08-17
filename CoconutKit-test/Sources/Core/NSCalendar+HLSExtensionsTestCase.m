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
@property (nonatomic, retain) NSTimeZone *timeZone1;
@property (nonatomic, retain) NSTimeZone *timeZone2;
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
    self.timeZone1 = nil;
    self.timeZone2 = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize calendar = m_calendar;

@synthesize timeZone1 = m_timeZone1;

@synthesize timeZone2 = m_timeZone2;

@synthesize date1 = m_date1;

@synthesize date2 = m_date2;

#pragma mark Test setup and tear down

- (void)setUp
{
    [super setUp];
    
    // Code to be run before each test
}

- (void)tearDown 
{
    [super tearDown];
    
    // Code to be run after each test
}

- (void)setUpClass
{
    [super setUpClass];
    
    self.calendar = [NSCalendar currentCalendar];
    
    self.timeZone1 = [NSTimeZone timeZoneWithName:@"Europe/Zurich"];
    self.timeZone2 = [NSTimeZone timeZoneWithName:@"Pacific/Tahiti"];           // timeZone1 - 12 hours
    
    NSDateComponents *dateComponents1 = [[[NSDateComponents alloc] init] autorelease];
    [dateComponents1 setYear:2012];
    [dateComponents1 setMonth:1];
    [dateComponents1 setDay:1];
    [dateComponents1 setHour:8];
    [dateComponents1 setMinute:23];
    self.date1 = [self.calendar dateFromComponents:dateComponents1 inTimeZone:self.timeZone1];
    
    NSDateComponents *dateComponents2 = [[[NSDateComponents alloc] init] autorelease];
    [dateComponents2 setYear:2012];
    [dateComponents2 setMonth:3];
    [dateComponents2 setDay:1];
    [dateComponents2 setHour:6];
    [dateComponents2 setMinute:12];
    self.date2 = [self.calendar dateFromComponents:dateComponents2 inTimeZone:self.timeZone1];
}

#pragma mark Tests

// Insert methods beginnning with test... here. Log with GHTestLog

@end
