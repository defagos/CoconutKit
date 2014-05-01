//
//  CAMediaTimingFunction+HLExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 9/7/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CAMediaTimingFunction+HLExtensionsTestCase.h"

@interface CAMediaTimingFunction (CAPrivate)

// Private method used to compute function values. Use them as reference, tests will never make it to the AppStore
// after all
- (float)_solveForInput:(float)arg1;

@end

@implementation CAMediaTimingFunction_HLExtensionsTestCase

#pragma mark Tests

- (void)testEvaluation
{
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
}

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

#pragma mark Helpers

- (void)checkValuesForTimingFunction:(CAMediaTimingFunction *)timingFunction
{
    static const NSUInteger kNumberOfSamples = 101;
    
    NSLog(@"-----------------------------");
    for (NSUInteger i = 0; i < kNumberOfSamples; ++i) {
        float time = (float)i / (kNumberOfSamples - 1);
        NSLog(@"Sample %d: Custom = %.12f, built-in = %.12f", i, [timingFunction valueForNormalizedTime:time], [timingFunction _solveForInput:time]);
        
        // Check that built-in results and custom implementation match to at least 4 digits
        // GHAssertTrue(floatlt(fabsf([timingFunction valueForNormalizedTime:time] - [timingFunction _solveForInput:time]), 1e-2), nil);
    }
}

@end
