//
//  NSDate+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 17.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensionsTestCase.h"

@interface NSDate_HLSExtensionsTestCase ()

@end

@implementation NSDate_HLSExtensionsTestCase

#pragma mark Tests

- (void)testDateComparisons
{
    NSDate *date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:100000.];
    NSDate *date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:100001.];
    
    GHAssertTrue([date1 isEarlierThanDate:date2], @"Earlier date");
    
    GHAssertTrue([date1 isEarlierThanOrEqualToDate:date2], @"Earlier or equal date");
    GHAssertTrue([date1 isEarlierThanOrEqualToDate:date1], @"Earlier or equal date");
    
    GHAssertTrue([date2 isLaterThanDate:date1], @"Later date");
    
    GHAssertTrue([date1 isLaterThanOrEqualToDate:date1], @"Later date");
    GHAssertTrue([date1 isLaterThanOrEqualToDate:date1], @"Later date");
}

@end
