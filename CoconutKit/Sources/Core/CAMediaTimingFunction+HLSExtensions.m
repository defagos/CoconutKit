//
//  CAMediaTimingFunction+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "CAMediaTimingFunction+HLSExtensions.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"

// Associated object keys
static void *s_polynomialCoefficientsKey = &s_polynomialCoefficientsKey;

// Cubic polynomial coefficients derived from the control points
typedef struct {
    float cx;
    float bx;
    float ax;
    float cy;
    float by;
    float ay;
} PolynomialCoefficients;

// Tolerance for zero finding. Results obtained in very good agreement with those of the private -_solveForInput:
// method
static const float kEpsilon = 1e-5f;

@implementation CAMediaTimingFunction (HLSExtensions)

- (float)valueForNormalizedTime:(float)time
{
    if (isless(time, 0.f)) {
        HLSLoggerWarn(@"Time must be >= 0. Fixed to 0");
        time = 0.f;
    }
    else if (isgreater(time, 1.f)) {
        HLSLoggerWarn(@"Time must be <= 1. Fixed to 1");
        time = 1.f;
    }
    
    PolynomialCoefficients coeffs = [self polynomialCoefficients];
    float t = [self tWithX:time forCurveWithPolynomialCoefficients:coeffs];
    return [self yAtT:t forCurveWithPolynomialCoefficients:coeffs];
}

#pragma mark Calculation

// Implementation borrowed from WebKit:
//   http://opensource.apple.com/source/WebCore/WebCore-7537.70/platform/graphics/UnitBezier.h
// Reproduces the results returned by the private _solveForInput: method

// Compute and cache polynomial coefficients
- (PolynomialCoefficients)polynomialCoefficients
{
    NSValue *coeffsValue = hls_getAssociatedObject(self, s_polynomialCoefficientsKey);
    if (! coeffsValue) {
        float p1[2];
        memset(p1, 0, sizeof(p1));
        [self getControlPointAtIndex:1 values:p1];
        
        float p2[2];
        memset(p2, 0, sizeof(p2));
        [self getControlPointAtIndex:2 values:p2];
        
        PolynomialCoefficients coeffs;
        memset(&coeffs, 0, sizeof(PolynomialCoefficients));
        
        // Cubic Bézier curve parametric equations
        coeffs.cx = 3.f * p1[0];
        coeffs.bx = 3.f * (p2[0] - p1[0]) - coeffs.cx;
        coeffs.ax = 1.f - coeffs.cx - coeffs.bx;
        
        coeffs.cy = 3.f * p1[1];
        coeffs.by = 3.f * (p2[1] - p1[1]) - coeffs.cy;
        coeffs.ay = 1.f - coeffs.cy - coeffs.by;
        
        coeffsValue = [NSValue value:&coeffs withObjCType:@encode(PolynomialCoefficients)];
        hls_setAssociatedObject(self, s_polynomialCoefficientsKey, coeffsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return coeffs;
    }
    
    PolynomialCoefficients coeffs;
    memset(&coeffs, 0, sizeof(PolynomialCoefficients));
    [coeffsValue getValue:&coeffs];
    
    return coeffs;
}

- (float)xAtT:(float)t forCurveWithPolynomialCoefficients:(PolynomialCoefficients)coeffs
{
    // `ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
    return ((coeffs.ax * t + coeffs.bx) * t + coeffs.cx) * t;
}

- (float)yAtT:(float)t forCurveWithPolynomialCoefficients:(PolynomialCoefficients)coeffs
{
    return ((coeffs.ay * t + coeffs.by) * t + coeffs.cy) * t;
}

- (float)xAtT:(float)t forDerivativeOfCurveWithPolynomialCoefficients:(PolynomialCoefficients)coeffs
{
    return (3.f * coeffs.ax * t + 2.f * coeffs.bx) * t + coeffs.cx;
}

// Given an x value, find a parametric value it came from (t is not the time).
- (float)tWithX:(float)x forCurveWithPolynomialCoefficients:(PolynomialCoefficients)coeffs
{
    float t0 = 0.f;
    float t1 = 0.f;
    float t2 = x;
    float x2 = 0.f;
    float d2 = 0.f;
    
    // First try a few iterations of Newton's method -- normally very fast.
    for (int i = 0; i < 8; i++) {
        x2 = [self xAtT:t2 forCurveWithPolynomialCoefficients:coeffs] - x;
        if (isless(fabsf(x2), kEpsilon)) {
            return t2;
        }
        d2 = [self xAtT:t2 forDerivativeOfCurveWithPolynomialCoefficients:coeffs];
        if (isless(fabsf(d2), 1e-6f /* fixed tolerance for small denominators */)) {
            break;
        }
        t2 -= x2 / d2;
    }
    
    // Fall back to the bisection method for reliability.
    t0 = 0.f;
    t1 = 1.f;
    t2 = x;
    
    if (isless(t2, t0)) {
        return t0;
    }
    
    if (isgreater(t2, t1)) {
        return t1;
    }
    
    while (isless(t0, t1)) {
        x2 = [self xAtT:t2 forCurveWithPolynomialCoefficients:coeffs];
        if (isless(fabsf(x2 - x), kEpsilon)) {
            return t2;
        }
        
        if (isgreater(x, x2)) {
            t0 = t2;
        }
        else {
            t1 = t2;
        }
        
        t2 = (t1 - t0) * 0.5f + t0;
    }
    
    // Failure.
    return t2;
}

#pragma mark Helpers

- (CAMediaTimingFunction *)inverseFunction
{
    float values1[2];
    memset(values1, 0, sizeof(values1));
    [self getControlPointAtIndex:1 values:values1];
     
    float values2[2];
    memset(values2, 0, sizeof(values2));
    [self getControlPointAtIndex:2 values:values2];
    
    // Flip the original curve around the y = 1 - x axis
    // Refer to the "Introduction to Animation Types and Timing Programming Guide"
    return [CAMediaTimingFunction functionWithControlPoints:1.f - values2[0] :values1[1] :1.f - values1[0] :values2[1]];
}

- (NSString *)controlPointsString
{
    NSMutableString *controlPointsString = [NSMutableString stringWithString:@"["];
    
    for (size_t i = 0; i < 4; ++i) {
        float values[2];
        memset(values, 0, sizeof(values));
        [self getControlPointAtIndex:i values:values];
        [controlPointsString appendFormat:@"(%.2f, %.2f)", values[0], values[1]];
        
        if (i != 3) {
            [controlPointsString appendString:@", "];
        }
    }
    [controlPointsString appendString:@"]"];
    
    return [NSString stringWithString:controlPointsString];
}

@end
