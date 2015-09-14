//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CAMediaTimingFunction+HLExtensionsTestCase.h"

@interface CAMediaTimingFunction (CAPrivate)

// Private method used to compute function values. Use them as reference, tests will never make it to the AppStore
// after all
- (float)_solveForInput:(float)normalizedTime;

@end

@implementation CAMediaTimingFunction_HLExtensionsTestCase

#pragma mark Tests

- (void)testEvaluation
{
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.45f :0.5f :1.f :1.f]];
    [self checkValuesForTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.25f :0.85f :0.7f :0.3f]];
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
        
        XCTAssertEqual(inverseEaseInValues[0], easeOutValues[0]);
        XCTAssertEqual(inverseEaseInValues[1], easeOutValues[1]);
    }
}

#pragma mark Helpers

- (void)checkValuesForTimingFunction:(CAMediaTimingFunction *)timingFunction
{
    static const NSUInteger kNumberOfSamples = 1001;
    
    // Check that built-in results and custom implementation match to at least 4 digits
    for (NSUInteger i = 0; i < kNumberOfSamples; ++i) {
        float time = (float)i / (kNumberOfSamples - 1);
        XCTAssertTrue(isless(fabsf([timingFunction valueForNormalizedTime:time] - [timingFunction _solveForInput:time]), 1e-4));
    }
}

@end
