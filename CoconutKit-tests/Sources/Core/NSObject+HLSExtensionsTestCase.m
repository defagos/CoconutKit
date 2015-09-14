//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSObject+HLSExtensionsTestCase.h"

@implementation NSObject_HLSExtensionsTestCase

#pragma mark Tests

// Warning: -testClassName crashes the test, because the method is a private XCTest.framework method. See
//   nm /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Frameworks/XCTest.framework/XCTest
- (void)testNameOfClass
{
    XCTAssertEqualObjects([XCTestCase className], @"XCTestCase");
    XCTAssertEqualObjects([self className], @"NSObject_HLSExtensionsTestCase");
}

@end
