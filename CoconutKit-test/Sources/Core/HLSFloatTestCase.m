//
//  HLSFloatTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSFloatTestCase.h"

@implementation HLSFloatTestCase

#pragma mark Tests

- (void)testComparisons
{
    GHAssertTrue(floateq(1.f, 1.f), nil);
    GHAssertFalse(floateq(1.f, 2.f), nil);
    GHAssertFalse(floateq(-1.f, 4.f), nil);
    
    GHAssertTrue(doubleeq(1., 1.), nil);
    GHAssertFalse(doubleeq(1., 2.), nil);
    GHAssertFalse(doubleeq(-1., 4.), nil);

    GHAssertTrue(floatle(1.f, 1.f), nil);
    GHAssertTrue(floatle(1.f, 2.f), nil);
    GHAssertFalse(floatle(2.f, 1.f), nil);
    
    GHAssertTrue(floatge(1.f, 1.f), nil);
    GHAssertTrue(floatge(2.f, 1.f), nil);
    GHAssertFalse(floatge(1.f, 2.f), nil);

    GHAssertTrue(floatlt(1.f, 2.f), nil);
    GHAssertFalse(floatlt(2.f, 1.f), nil);
    
    GHAssertTrue(floatgt(2.f, 1.f), nil);
    GHAssertFalse(floatgt(1.f, 2.f), nil);
    
    GHAssertTrue(doublele(1., 1.), nil);
    GHAssertTrue(doublele(1., 2.), nil);
    GHAssertFalse(doublele(2., 1.), nil);
    
    GHAssertTrue(doublege(1., 1.), nil);
    GHAssertTrue(doublege(2., 1.), nil);
    GHAssertFalse(doublege(1., 2.), nil);
    
    GHAssertTrue(doublelt(1., 2.), nil);
    GHAssertFalse(doublelt(2., 1.), nil);
    
    GHAssertTrue(doublegt(2., 1.), nil);
    GHAssertFalse(doublegt(1., 2.), nil);
    
    GHAssertEquals(floatmin(1.f, 1.f), 1.f, nil);
    GHAssertEquals(floatmin(1.f, 2.f), 1.f, nil);
    
    GHAssertEquals(floatmax(1.f, 1.f), 1.f, nil);
    GHAssertEquals(floatmax(1.f, 2.f), 2.f, nil);

    GHAssertEquals(doublemin(1., 1.), 1., nil);
    GHAssertEquals(doublemin(1., 2.), 1., nil);
    
    GHAssertEquals(doublemax(1., 1.), 1., nil);
    GHAssertEquals(doublemax(1., 2.), 2., nil);
}

@end
