//
//  UIView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIView+HLSExtensions.h"

#import <objc/runtime.h>
#import "CALayer+HLSExtensions.h"
#import "HLSRuntime.h"

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

- (void)fadeLeftBorder:(CGFloat)left rightBorder:(CGFloat)right
{
	CGFloat width = CGRectGetWidth(self.frame);
    
	CAGradientLayer *maskLayer = [self gradientMaskLayer];
	maskLayer.locations = @[@(0.0), @(left/width), @(1.0-right/width), @(1.0)];
	maskLayer.startPoint = CGPointMake(0.0, 0.0);
	maskLayer.endPoint = CGPointMake(1.0, 0.0);
	
	self.layer.mask = maskLayer;
}

- (void)fadeBottomBorder:(CGFloat)bottom topBorder:(CGFloat)top
{
	CGFloat height = CGRectGetHeight(self.frame);
    
	CAGradientLayer *maskLayer = [self gradientMaskLayer];
	maskLayer.locations = @[@(0.0), @(bottom/height), @(1.0-top/height), @(1.0)];
	maskLayer.startPoint = CGPointMake(0.0, 1.0);
	maskLayer.endPoint = CGPointMake(0.0, 0.0);
	
	self.layer.mask = maskLayer;
}

- (CAGradientLayer*) gradientMaskLayer
{
	CAGradientLayer *maskLayer = [CAGradientLayer layer];
	
	UIColor *outerColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	UIColor *innerColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	
	maskLayer.colors = @[(id)outerColor.CGColor, (id)innerColor.CGColor, (id)innerColor.CGColor, (id)outerColor.CGColor];
	
	maskLayer.bounds = self.bounds;
	maskLayer.anchorPoint = CGPointZero;
    
	return maskLayer;
}

@end
