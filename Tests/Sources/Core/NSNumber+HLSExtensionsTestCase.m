//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import CoconutKit;
@import XCTest;

@interface NSNumber_HLSExtensionsTestCase : XCTestCase
@end

@implementation NSNumber_HLSExtensionsTestCase

- (void)testNumberComparisons
{
    XCTAssertTrue([[@1 minimumNumber:@2] isEqualToNumber:@1]);
    XCTAssertTrue([[@1 maximumNumber:@2] isEqualToNumber:@2]);
    
    XCTAssertTrue([@1 isLessThanNumber:@2]);
    
    XCTAssertTrue([@1 isLessThanOrEqualToNumber:@2]);
    XCTAssertTrue([@1 isLessThanOrEqualToNumber:@1]);
    
    XCTAssertTrue([@2 isGreaterThanNumber:@1]);
    
    XCTAssertTrue([@2 isGreaterThanOrEqualToNumber:@1]);
    XCTAssertTrue([@2 isGreaterThanOrEqualToNumber:@1]);
}

@end
