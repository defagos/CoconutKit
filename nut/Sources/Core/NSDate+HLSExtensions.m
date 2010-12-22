//
//  NSDate+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensions.h"

@implementation NSDate (HLSExtensions)

- (NSComparisonResult)compareDaysWithDate:(NSDate *)date
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

- (BOOL)isSameDayAsDate:(NSDate *)date
{
    NSComparisonResult comparisonResult = [self compareDaysWithDate:date];
    return comparisonResult == NSOrderedSame;
}

@end
