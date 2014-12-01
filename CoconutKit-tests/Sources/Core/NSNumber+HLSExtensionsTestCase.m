//
//  NSNumber+HLSExtensionsTestCase.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.06.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "NSNumber+HLSExtensionsTestCase.h"

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
