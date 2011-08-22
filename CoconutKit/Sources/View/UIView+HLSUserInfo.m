//
//  UIView+HLSUserInfo.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIView+HLSUserInfo.h"

#import <objc/runtime.h>
#import "HLSRuntime.h"

static void *s_userInfoKey = &s_userInfoKey;

@implementation UIView (HLSUserInfo)

#pragma mark Accessors and mutators

- (NSDictionary *)userInfo_hls
{
    return objc_getAssociatedObject(self, s_userInfoKey);
}

- (void)setUserInfo_hls:(NSDictionary *)userInfo_hls
{
    objc_setAssociatedObject(self, s_userInfoKey, userInfo_hls, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
