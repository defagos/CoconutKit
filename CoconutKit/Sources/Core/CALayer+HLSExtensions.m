//
//  CALayer+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CALayer+HLSExtensions.h"

#import "HLSLogger.h"

@implementation CALayer (HLSExtensions)

- (void)removeAllAnimationsRecursively
{
    [self removeAllAnimations];
    
    for (CALayer *sublayer in self.sublayers) {
        [sublayer removeAllAnimationsRecursively];
    }
}

- (void)resetAnimations
{
    // If layer animations had been paused, reset the layer status
    NSNumber *pausedSpeedNumber = [self valueForKey:@"HLSPausedSpeed"];
    if (pausedSpeedNumber) {
        self.speed = [pausedSpeedNumber doubleValue];
        [self setValue:nil forKey:@"HLSPausedSpeed"];
    }
    
    self.timeOffset = 0.;
    self.beginTime = 0.;
}

// See https://developer.apple.com/library/ios/#qa/qa2009/qa1673.html for pausing / resuming layer animations
- (void)pauseAllAnimations
{
    NSNumber *pausedSpeedNumber = [self valueForKey:@"HLSPausedSpeed"];
    if (pausedSpeedNumber) {
        HLSLoggerDebug(@"Layer animations have already been paused");
        return;
    }
    [self setValue:[NSNumber numberWithDouble:self.speed] forKey:@"HLSPausedSpeed"];
    
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.f;
    self.timeOffset = pausedTime;
}

- (void)resumeAllAnimations
{
    NSNumber *pausedSpeedNumber = [self valueForKey:@"HLSPausedSpeed"];
    if (! pausedSpeedNumber) {
        HLSLoggerDebug(@"Layer animations have not been paused");
        return;        
    }
    
    CFTimeInterval pausedTime = self.timeOffset;
    self.speed = [pausedSpeedNumber doubleValue];
    self.timeOffset = 0.;
    self.beginTime = 0.;        // Very important! Changes the result of the convertTime:fromLayer: calculation!
    CFTimeInterval timeInt = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeInt;
    [self setValue:nil forKey:@"HLSPausedSpeed"];
}

- (BOOL)areAllAnimationsPaused
{
    return [self valueForKey:@"HLSPausedSpeed"] != nil;
}

@end
