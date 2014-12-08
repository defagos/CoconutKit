//
//  UIControl+HLSExclusiveTouch.m
//  CoconutKit
//
//  Created by Samuel Défago on 07.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "UIControl+HLSExclusiveTouch.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UIControl *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UIControl *self, SEL _cmd, NSCoder *aDecoder);

@implementation UIControl (HLSExclusiveTouch)

#pragma mark Class methods

+ (void)enableExclusiveTouch
{
    static BOOL s_injected = NO;
    if (s_injected) {
        HLSLoggerInfo(@"Exclusive touch already injected");
        return;
    }
    
    // Swizzle the original implementations (keep a hand on them)
    s_initWithFrame = (__typeof(s_initWithFrame))hls_class_swizzleSelector(self, @selector(initWithFrame:), (IMP)swizzle_initWithFrame);
    s_initWithCoder = (__typeof(s_initWithCoder))hls_class_swizzleSelector(self, @selector(initWithCoder:), (IMP)swizzle_initWithCoder);
    
    s_injected = YES;
}

@end

#pragma mark Static functions

static void commonInit(UIControl *self)
{
    self.exclusiveTouch = YES;
}

static id swizzle_initWithFrame(UIControl *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_initWithFrame)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UIControl *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_initWithCoder)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}
