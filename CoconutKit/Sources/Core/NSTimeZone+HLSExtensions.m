//
//  NSTimeZone+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 05.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSTimeZone+HLSExtensions.h"

#import "HLSCategoryLinker.h"

HLSLinkCategory(NSTimeZone_HLSExtensions)

@implementation NSTimeZone (HLSExtensions)

- (NSTimeInterval)offsetFromTimeZone:(NSTimeZone *)timeZone forDate:(NSDate *)date
{
    return [self secondsFromGMTForDate:date] - [timeZone secondsFromGMTForDate:date];
}

@end
