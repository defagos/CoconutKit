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
    [self getControlPointAtIndex:1 values:values1];
     
    float values2[2];
    [self getControlPointAtIndex:2 values:values2];
    
    return [CAMediaTimingFunction functionWithControlPoints:1.f - values2[0] :values1[1] :1.f - values1[0] :values2[1]];
}

- (NSString *)controlPointsString
{
    NSMutableString *controlPointsString = [NSMutableString stringWithString:@"["];
    
    float values[2];
    for (size_t i = 0; i < 4; ++i) {
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
