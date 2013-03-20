//
//  UIView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIView+HLSExtensions.h"

#import "CALayer+HLSExtensions.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"

// Keys for associated objects
static void *s_tagKey = &s_tagKey;
static void *s_userInfoKey = &s_userInfoKey;

@implementation UIView (HLSExtensions)

#pragma mark Accessors and mutators

- (NSString *)tag_hls
{
    return objc_getAssociatedObject(self, s_tagKey);
}

- (void)setTag_hls:(NSString *)tag_hls
{
    objc_setAssociatedObject(self, s_tagKey, tag_hls, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)userInfo_hls
{
    return objc_getAssociatedObject(self, s_userInfoKey);
}

- (void)setUserInfo_hls:(NSDictionary *)userInfo_hls
{
    objc_setAssociatedObject(self, s_userInfoKey, userInfo_hls, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)flattenedImage
{
    return [self.layer flattenedImage];
}

#pragma mark View fading

- (void)fadeLeft:(CGFloat)left right:(CGFloat)right
{
    if (floatlt(left, 0.f) || floatlt(right, 0.f) || floatgt(left + right, 1.f)) {
        HLSLoggerWarn(@"Invalid values for fading parameters. Must be >= 0 and must not add up to a value larger than 1");
        return;
    }
    
    CAGradientLayer *gradientLayer = [self gradientMaskLayer];
	gradientLayer.locations = @[@(0.f), @(left), @(1.f - right), @(1.f)];
	gradientLayer.startPoint = CGPointMake(0.f, 0.f);
	gradientLayer.endPoint = CGPointMake(1.f, 0.f);
    self.layer.mask = gradientLayer;
}

- (void)fadeTop:(CGFloat)top bottom:(CGFloat)bottom
{
    if (floatlt(top, 0.f) || floatlt(bottom, 0.f) || floatgt(top + bottom, 1.f)) {
        HLSLoggerWarn(@"Invalid values for fading parameters. Must be >= 0 and must not add up to a value larger than 1");
        return;
    }

    CAGradientLayer *gradientLayer = [self gradientMaskLayer];
	gradientLayer.locations = @[@(0.f), @(top), @(1.f - bottom), @(1.f)];
	gradientLayer.startPoint = CGPointMake(0.f, 0.f);
	gradientLayer.endPoint = CGPointMake(0.f, 1.f);
	self.layer.mask = gradientLayer;
}

- (CAGradientLayer *)gradientMaskLayer
{
	CAGradientLayer *maskLayer = [CAGradientLayer layer];
	
	UIColor *outerColor = [UIColor colorWithWhite:1.f alpha:0.f];
	UIColor *innerColor = [UIColor colorWithWhite:1.f alpha:1.f];
	
	maskLayer.colors = @[(id)outerColor.CGColor, (id)innerColor.CGColor, (id)innerColor.CGColor, (id)outerColor.CGColor];
	
	maskLayer.bounds = self.bounds;
	maskLayer.anchorPoint = CGPointZero;
    
	return maskLayer;
}

@end
