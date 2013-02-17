//
//  NSArray+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSArray+HLSExtensionsTestCase.h"

@implementation NSArray_HLSExtensionsTestCase

#pragma mark Tests

- (void)testFirstObject
{
    NSArray *emptyArray = [NSArray array];
    GHAssertNil([emptyArray firstObject_hls], nil);
    
    NSArray *array = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    GHAssertEqualStrings([array firstObject_hls], @"1", nil);
}

- (void)testRotation
{
    NSArray *array = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    
    NSArray *leftArray = [array arrayByLeftRotatingNumberOfObjects:2];
    NSArray *expectedLeftArray = [NSArray arrayWithObjects:@"3", @"1", @"2", nil];
    GHAssertTrue([leftArray isEqualToArray:expectedLeftArray], nil);
    
    NSArray *rightArray = [array arrayByRightRotatingNumberOfObjects:2];
    NSArray *expectedRightArray = [NSArray arrayWithObjects:@"2", @"3", @"1", nil];
    GHAssertTrue([rightArray isEqualToArray:expectedRightArray], nil);
}

- (void)testSafeInsert
{
    NSMutableArray *array = [NSMutableArray array];
    [array safelyAddObject:nil];
    GHAssertEquals([array count], 0U, nil);
}

@end
