//
//  NSArray+HLSExtensionsTestCase.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSArray+HLSExtensionsTestCase.h"

@implementation NSArray_HLSExtensionsTestCase

#pragma mark Tests

- (void)testRotation
{
    NSArray *array = @[@"1", @"2", @"3"];
    
    NSArray *leftArray = [array arrayByLeftRotatingNumberOfObjects:2];
    NSArray *expectedLeftArray = @[@"3", @"1", @"2"];
    GHAssertTrue([leftArray isEqualToArray:expectedLeftArray], nil);
    
    NSArray *rightArray = [array arrayByRightRotatingNumberOfObjects:2];
    NSArray *expectedRightArray = @[@"2", @"3", @"1"];
    GHAssertTrue([rightArray isEqualToArray:expectedRightArray], nil);
}

- (void)testSafeInsert
{
    NSMutableArray *array = [NSMutableArray array];
    [array safelyAddObject:nil];
    GHAssertEquals([array count], (NSUInteger)0, nil);
}

@end
