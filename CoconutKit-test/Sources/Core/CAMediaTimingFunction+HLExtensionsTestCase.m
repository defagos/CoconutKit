//
//  CAMediaTimingFunction+HLExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 9/7/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CAMediaTimingFunction+HLExtensionsTestCase.h"

@implementation CAMediaTimingFunction_HLExtensionsTestCase

#pragma mark Tests

- (void)testInverse
{
    // Inverse ease in must be ease out
    CAMediaTimingFunction *inverseEaseInTimingFunction = [[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn] inverseFunction];
    CAMediaTimingFunction *easeOutTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    for (size_t i = 0; i < 4; ++i) {
        float inverseEaseInValues[2];
        memset(inverseEaseInValues, 0, sizeof(inverseEaseInValues));
        [inverseEaseInTimingFunction getControlPointAtIndex:i values:inverseEaseInValues];
        
        float easeOutValues[2];
        memset(easeOutValues, 0, sizeof(easeOutValues));
        [easeOutTimingFunction getControlPointAtIndex:i values:easeOutValues];
        
        GHAssertTrue(floateq(inverseEaseInValues[0], easeOutValues[0]), nil);
        GHAssertTrue(floateq(inverseEaseInValues[1], easeOutValues[1]), nil);
    }
}

@end
