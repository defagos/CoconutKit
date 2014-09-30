//
//  CALayer+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "CALayer+HLSExtensions.h"

#import "HLSLogger.h"

static NSString * const kLayerSpeedBeforePauseKey = @"HLSLayerSpeedBeforePause";

@interface CALayer (HLSExtensionsPrivate)

- (void)resetAnimations;

@end

@implementation CALayer (HLSExtensions)

- (void)removeAllAnimationsRecursively
{
    // If we cancel animations for a layer which had been paused, reset its properties. In all other cases,
    // the layer properties will end up correctly at the end of the animation (the end of an animation is
    // only reached if the animation is not paused, and resuming animation restores layer properties)
    [self resetAnimations];
    
    [self removeAllAnimations];
    
    for (CALayer *sublayer in self.sublayers) {
        [sublayer removeAllAnimationsRecursively];
    }
}

/**
 * See https://developer.apple.com/library/ios/#qa/qa2009/qa1673.html for pausing / resuming layer animations
 *
 * Important remark: Time conversion involves speed, timeOffset and beginTime: From -timeOffset documentation,
 *                   we have for fromLayer = nil;
 *                     t' = (t - beginTime) * speed + timeOffset
 *                   The order of the setSpeed:, setTimeOffset:, setBeginTime: and convertTime:fromLayer:
 *                   calls below is therefore VERY important, and temporary variables are sometimes
 *                   absolutely mandatory to get a correct result
 */
- (void)pauseAllAnimations
{
    NSNumber *speedBeforePauseNumber = [self valueForKey:kLayerSpeedBeforePauseKey];
    if (speedBeforePauseNumber) {
        HLSLoggerDebug(@"Layer animations have already been paused");
        return;
    }
    [self setValue:@(self.speed) forKey:kLayerSpeedBeforePauseKey];
    
    // Call order / use of temporaries is very important here! See remark above!
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.f;
    self.timeOffset = pausedTime;
}

- (void)resumeAllAnimations
{
    NSNumber *speedBeforePauseNumber = [self valueForKey:kLayerSpeedBeforePauseKey];
    if (! speedBeforePauseNumber) {
        HLSLoggerDebug(@"Layer animations have not been paused");
        return;        
    }
    
    // Call order / use of temporaries is very important here! See remark above!
    CFTimeInterval pausedTime = self.timeOffset;
    self.speed = [speedBeforePauseNumber floatValue];
    self.timeOffset = 0.;
    self.beginTime = 0.;
    CFTimeInterval timeIntervalSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeIntervalSincePause;
    
    [self setValue:nil forKey:kLayerSpeedBeforePauseKey];
}

- (BOOL)isPaused
{
    return [self valueForKey:kLayerSpeedBeforePauseKey] != nil;
}

// See http://developer.apple.com/library/ios/#qa/qa1703/_index.html
- (UIImage *)flattenedImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.f /* use the device scale factor */);
    
    // -renderInContext: renders in the layer coordinate space, i.e. the origin of the layer is ignored. This has
    // to be fixed before creating the image
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    CGContextConcatCTM(context, CATransform3DGetAffineTransform(self.transform));
    CGContextTranslateCTM(context,
                          -CGRectGetWidth(self.bounds) * self.anchorPoint.x,
                          -CGRectGetHeight(self.bounds) * self.anchorPoint.y);
    [self renderInContext:context];
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation CALayer (HLSExtensionsPrivate)

- (void)resetAnimations
{
    // If layer animations had been paused, reset the layer status
    NSNumber *speedBeforePauseNumber = [self valueForKey:kLayerSpeedBeforePauseKey];
    if (speedBeforePauseNumber) {
        self.speed = [speedBeforePauseNumber floatValue];
        [self setValue:nil forKey:kLayerSpeedBeforePauseKey];
    }
    
    self.timeOffset = 0.;
    self.beginTime = 0.;
}

@end
