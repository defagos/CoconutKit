//
//  NSDate+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensions.h"

@implementation NSDate (HLSExtensions)

- (BOOL)isSameDayAsDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents *dateComponents2 = [calendar components:unitFlags fromDate:date];
    
    return [dateComponents1 day] == [dateComponents2 day]
        && [dateComponents1 month] == [dateComponents2 month]
        && [dateComponents1 year] == [dateComponents2 year];
}

@end
