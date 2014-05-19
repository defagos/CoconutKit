//
//  NSObject+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSObject+HLSExtensionsTestCase.h"

@implementation NSObject_HLSExtensionsTestCase

#pragma mark Tests

- (void)testClassName
{
    GHAssertEqualStrings([GHTestCase className], @"GHTestCase", nil);
    GHAssertEqualStrings([self className], @"NSObject_HLSExtensionsTestCase", nil);
}

@end
