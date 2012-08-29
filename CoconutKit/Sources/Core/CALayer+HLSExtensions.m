//
//  CALayer+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CALayer+HLSExtensions.h"

@implementation CALayer (HLSExtensions)

- (void)removeAllAnimationsRecursively
{
    [self removeAllAnimations];
    for (CALayer *sublayer in self.sublayers) {
        [sublayer removeAllAnimationsRecursively];
    }
}

- (void)togglePauseAnimations
{
    // See https://developer.apple.com/library/ios/#qa/qa2009/qa1673.html
    NSNumber *pausedSpeedNumber = [self valueForKey:@"HLSPausedSpeed"];
    if (! pausedSpeedNumber) {
        [self setValue:[NSNumber numberWithDouble:self.speed] forKey:@"HLSPausedSpeed"];
        
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0.f;
        self.timeOffset = pausedTime;
    }
    else {
        CFTimeInterval pausedTime = self.timeOffset;
        self.speed = [pausedSpeedNumber doubleValue];
        self.timeOffset = 0.;
        self.beginTime = 0.;        // Very important! Changes the result of the convertTime:fromLayer: calculation!
        self.beginTime = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        [self setValue:nil forKey:@"HLSPausedSpeed"];
    }
}

@end
