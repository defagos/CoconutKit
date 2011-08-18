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

// Original implementation of the methods we swizzle
static void (*s_UIView__dealloc_Imp)(id, SEL) = NULL;

static void *s_userInfoKey = &s_userInfoKey;

@interface UIView (HLSUserInfoPrivate)

- (void)swizzledDealloc;

@end

@implementation UIView (HLSUserInfo)

#pragma mark Class methods

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [UIView class]) {
        return;
    }
    
    s_UIView__dealloc_Imp = (void (*)(id, SEL))HLSSwizzleSelector([UIView class], @selector(dealloc), @selector(swizzledDealloc));
}

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

@implementation UIView (HLSUserInfoPrivate)

#pragma mark Methods injected by swizzling

- (void)swizzledDealloc
{
    objc_setAssociatedObject(self, s_userInfoKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    s_UIView__dealloc_Imp(self, @selector(dealloc));
}

@end
