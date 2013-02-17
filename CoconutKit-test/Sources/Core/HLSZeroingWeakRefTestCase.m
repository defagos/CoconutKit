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
    GHAssertNotNil(zeroingWeakRef.object, nil);
    [basicClass release];
    GHAssertNil(zeroingWeakRef.object, nil);
}

- (void)testTollFreeBridgedObject
{
    NSNumber *number = [[NSNumber alloc] initWithInt:1012];
    GHAssertThrows([[HLSZeroingWeakRef alloc] initWithObject:number], nil);
    [number release];
}

@end

@implementation BasicClass
@end
