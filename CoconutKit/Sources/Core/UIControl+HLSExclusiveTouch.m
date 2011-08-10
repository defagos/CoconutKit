//
//  UIControl+HLSExclusiveTouch.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 07.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIControl+HLSExclusiveTouch.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSCategoryLinker.h"

HLSLinkCategory(UIControl_HLSExclusiveTouch)

static BOOL m_injected = NO;

// Original implementation of the methods we swizzle
static id (*s_UIControl__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UIControl__initWithCoder_Imp)(id, SEL, id) = NULL;

#pragma mark -
#pragma mark UIControl (HLSExclusiveTouchPrivate) interface

@interface UIButton (HLSExclusiveTouchPrivate)

- (id)swizzledInitWithFrame:(CGRect)frame;
- (id)swizzledInitWithCoder:(NSCoder *)aDecoder;

@end

#pragma mark -
#pragma mark UIControl (HLSExclusiveTouch) implementation

@implementation UIControl (HLSExclusiveTouch)

#pragma mark Class methods

+ (void)injectExclusiveTouch
{
    if (m_injected) {
        HLSLoggerInfo(@"Exclusive touch already injected");
        return;
    }
    
    // Swizzle the original implementations (keep a hand on them)
    s_UIControl__initWithFrame_Imp = (id (*)(id, SEL, CGRect))HLSSwizzleSelector([self class], @selector(initWithFrame:), @selector(swizzledInitWithFrame:));
    s_UIControl__initWithCoder_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector([self class], @selector(initWithCoder:), @selector(swizzledInitWithCoder:));
    
    m_injected = YES;
}

@end

#pragma mark -
#pragma mark UIControl (HLSExclusiveTouchPrivate) implementation

@implementation UIControl (HLSExclusiveTouchPrivate)

#pragma mark Methods injected by swizzling

- (id)swizzledInitWithFrame:(CGRect)frame
{
    HLSLoggerDebug(@"Called swizzled initWithFrame:");
    
    // Call the original implementation
    if ((self = (*s_UIControl__initWithFrame_Imp)(self, @selector(initWithFrame:), frame))) {
        self.exclusiveTouch = YES;
    }
    return self;
}

- (id)swizzledInitWithCoder:(NSCoder *)aDecoder
{
    HLSLoggerDebug(@"Called swizzled initWithCoder:");
    
    // Call the original implementation
    if ((self = (*s_UIControl__initWithCoder_Imp)(self, @selector(initWithCoder:), aDecoder))) {
        self.exclusiveTouch = YES;
    }
    return self;
}

@end
