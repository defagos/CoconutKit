//
//  NSDate+HLSExtensionsTestCase.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.08.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSDate+HLSExtensionsTestCase.h"

@implementation NSDate_HLSExtensionsTestCase

#pragma mark Tests

- (void)testDateComparisons
{
    NSDate *date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:100000.];
    NSDate *date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:100001.];
    
    GHAssertTrue([date1 isEarlierThanDate:date2], nil);
    
    GHAssertTrue([date1 isEarlierThanOrEqualToDate:date2], nil);
    GHAssertTrue([date1 isEarlierThanOrEqualToDate:date1], nil);
    
    GHAssertTrue([date2 isLaterThanDate:date1], nil);
    
    GHAssertTrue([date1 isLaterThanOrEqualToDate:date1], nil);
    GHAssertTrue([date1 isLaterThanOrEqualToDate:date1], nil);
}

@end
