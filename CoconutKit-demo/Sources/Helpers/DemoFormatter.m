//
//  DemoFormatter.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "DemoFormatter.h"

@implementation DemoFormatter

+ (NSString *)stringFromDate:(NSDate *)date
{
    static NSDateFormatter *s_dateFormatter = nil;
    if (! s_dateFormatter) {
        s_dateFormatter = [[NSDateFormatter alloc] init];
        [s_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [s_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return [s_dateFormatter stringFromDate:date];
}

+ (NSString *)stringFromNumber:(NSNumber *)number
{
    static NSNumberFormatter *s_numberFormatter = nil;
    if (! s_numberFormatter) {
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        [s_numberFormatter setFormatterBehavior:NSNumberFormatterDecimalStyle];
    }
    return  [s_numberFormatter stringFromNumber:number];
}

@end
