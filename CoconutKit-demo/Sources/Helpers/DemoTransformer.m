//
//  DemoTransformer.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "DemoTransformer.h"

@implementation DemoTransformer

+ (NSDateFormatter *)mediumDateFormatter
{
    static dispatch_once_t s_onceToken;
    static NSDateFormatter *s_dateFormatter;
    dispatch_once(&s_onceToken, ^{
        s_dateFormatter = [[NSDateFormatter alloc] init];
        [s_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [s_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    });
    return s_dateFormatter;
}

+ (NSNumberFormatter *)decimalNumberFormatter
{
    static dispatch_once_t s_onceToken;
    static NSNumberFormatter *s_numberFormatter;
    dispatch_once(&s_onceToken, ^{
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        [s_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    return s_numberFormatter;
}

@end
