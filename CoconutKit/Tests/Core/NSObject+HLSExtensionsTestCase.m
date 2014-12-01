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

- (void)testClassName
{
    XCTAssertEqualObjects([XCTestCase className], @"XCTestCase");
    XCTAssertEqualObjects([self className], @"NSObject_HLSExtensionsTestCase");
}

@end
