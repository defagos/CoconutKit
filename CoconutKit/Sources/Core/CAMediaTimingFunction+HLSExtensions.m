//
//  CAMediaTimingFunction+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CAMediaTimingFunction+HLSExtensions.h"

@implementation CAMediaTimingFunction (HLSExtensions)

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
