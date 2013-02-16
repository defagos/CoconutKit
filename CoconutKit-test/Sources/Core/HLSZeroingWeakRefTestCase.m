//
//  HLSZeroingWeakRefTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 03.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSZeroingWeakRefTestCase.h"

@interface BasicClass : NSObject
@end

@implementation HLSZeroingWeakRefTestCase

#pragma mark Tests

- (void)testNonTollFreeBridgedObject
{
    BasicClass *basicClass = [[BasicClass alloc] init];
    HLSZeroingWeakRef *zeroingWeakRef = [[[HLSZeroingWeakRef alloc] initWithObject:basicClass] autorelease];
    GHAssertNotNil(zeroingWeakRef.object, @"Non-zeroed object reference");
    [basicClass release];
    GHAssertNil(zeroingWeakRef.object, @"Zeroed object reference");
}

- (void)testTollFreeBridgedObject
{
    NSNumber *number = [[NSNumber alloc] initWithInt:1012];
    GHAssertThrows([[HLSZeroingWeakRef alloc] initWithObject:number], @"Cannot create from Core Foundation objects");
    [number release];
}

@end

@implementation BasicClass
@end
