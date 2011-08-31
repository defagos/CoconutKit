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
    GHAssertTrue(floateq(1.f, 1.f), @"floateq");
    GHAssertFalse(floateq(1.f, 2.f), @"!floateq");
    GHAssertFalse(floateq(-1.f, 4.f), @"!floateq");
    
    GHAssertTrue(doubleeq(1., 1.), @"doubleeq");
    GHAssertFalse(doubleeq(1., 2.), @"!doubleeq");
    GHAssertFalse(doubleeq(-1., 4.), @"!doubleeq");

    GHAssertTrue(floatle(1.f, 1.f), @"floatle");
    GHAssertTrue(floatle(1.f, 2.f), @"floatle");
    GHAssertFalse(floatle(2.f, 1.f), @"!floatle");
    
    GHAssertTrue(floatge(1.f, 1.f), @"floatge");
    GHAssertTrue(floatge(2.f, 1.f), @"floatge");
    GHAssertFalse(floatge(1.f, 2.f), @"!floatge");

    GHAssertTrue(floatlt(1.f, 2.f), @"floatlt");
    GHAssertFalse(floatlt(2.f, 1.f), @"!floatlt");
    
    GHAssertTrue(floatgt(2.f, 1.f), @"floatgt");
    GHAssertFalse(floatgt(1.f, 2.f), @"!floatgt");
    
    GHAssertTrue(doublele(1., 1.), @"doublele");
    GHAssertTrue(doublele(1., 2.), @"doublele");
    GHAssertFalse(doublele(2., 1.), @"!doublele");
    
    GHAssertTrue(doublege(1., 1.), @"doublege");
    GHAssertTrue(doublege(2., 1.), @"doublege");
    GHAssertFalse(doublege(1., 2.), @"!doublege");
    
    GHAssertTrue(doublelt(1., 2.), @"doublelt");
    GHAssertFalse(doublelt(2., 1.), @"!doublelt");
    
    GHAssertTrue(doublegt(2., 1.), @"doublegt");
    GHAssertFalse(doublegt(1., 2.), @"!doublegt");
    
    GHAssertEquals(floatmin(1.f, 1.f), 1.f, @"floatmin");
    GHAssertEquals(floatmin(1.f, 2.f), 1.f, @"floatmin");
    
    GHAssertEquals(floatmax(1.f, 1.f), 1.f, @"floatmax");
    GHAssertEquals(floatmax(1.f, 2.f), 2.f, @"floatmax");

    GHAssertEquals(doublemin(1., 1.), 1., @"doublemin");
    GHAssertEquals(doublemin(1., 2.), 1., @"doublemin");
    
    GHAssertEquals(doublemax(1., 1.), 1., @"doublemax");
    GHAssertEquals(doublemax(1., 2.), 2., @"doublemax");
}

@end
