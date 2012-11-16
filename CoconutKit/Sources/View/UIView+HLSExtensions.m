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

@end
