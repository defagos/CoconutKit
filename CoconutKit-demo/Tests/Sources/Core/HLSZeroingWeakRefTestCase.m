//
//  HLSZeroingWeakRefTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 03.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSZeroingWeakRefTestCase.h"

@interface BasicClass : NSObject
@end

@implementation HLSZeroingWeakRefTestCase

#pragma mark Tests

- (void)testNonTollFreeBridgedObject
{
    BasicClass *basicClass = [[BasicClass alloc] init];
    HLSZeroingWeakRef *zeroingWeakRef = [[HLSZeroingWeakRef alloc] initWithObject:basicClass];
    GHAssertNotNil(zeroingWeakRef.object, nil);
}

- (void)testTollFreeBridgedObject
{
    GHAssertThrows([[HLSZeroingWeakRef alloc] initWithObject:@1012], nil);
}

@end

@implementation BasicClass
@end
