//
//  NSObject+HLSExtensionsTestCase.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
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
