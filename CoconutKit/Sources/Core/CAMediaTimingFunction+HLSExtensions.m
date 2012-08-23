//
//  CAMediaTimingFunction+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CAMediaTimingFunction+HLSExtensions.h"

@implementation CAMediaTimingFunction (HLSExtensions)

- (CAMediaTimingFunction *)inverse
{
    // TODO:
    return nil;
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
