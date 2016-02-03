//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSDate+HLSExtensionsTestCase.h"

@implementation NSDate_HLSExtensionsTestCase

#pragma mark Tests

- (void)testDateComparisons
{
    NSDate *date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:100000.];
    NSDate *date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:100001.];
    
    XCTAssertTrue([date1 isEarlierThanDate:date2]);
    
    XCTAssertTrue([date1 isEarlierThanOrEqualToDate:date2]);
    XCTAssertTrue([date1 isEarlierThanOrEqualToDate:date1]);
    
    XCTAssertTrue([date2 isLaterThanDate:date1]);
    
    XCTAssertTrue([date1 isLaterThanOrEqualToDate:date1]);
    XCTAssertTrue([date1 isLaterThanOrEqualToDate:date1]);
}

@end
