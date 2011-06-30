//
//  UIControl+HLSExclusiveTouch.m
//  nut-dev
//
//  Created by Samuel Défago on 07.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIControl+HLSExclusiveTouch.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"

static BOOL m_injected = NO;

// Original implementation of the methods we swizzle
static IMP s_initWithFrame$Imp;
static IMP s_initWithCoder$Imp;

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
        HLSLoggerWarn(@"Exclusive touch already injected");
        return;
    }
    
    // Swizzle the original implementations (keep a hand on them)
    s_initWithFrame$Imp = HLSSwizzleSelector([self class], @selector(initWithFrame:), @selector(swizzledInitWithFrame:));
    s_initWithCoder$Imp = HLSSwizzleSelector([self class], @selector(initWithCoder:), @selector(swizzledInitWithCoder:));
    
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
    if ((self = (*s_initWithFrame$Imp)(self, @selector(initWithFrame:), frame))) {
        self.exclusiveTouch = YES;
    }
    return self;
}

- (id)swizzledInitWithCoder:(NSCoder *)aDecoder
{
    HLSLoggerDebug(@"Called swizzled initWithCoder:");
    
    // Call the original implementation
    if ((self = (*s_initWithCoder$Imp)(self, @selector(initWithCoder:), aDecoder))) {
        self.exclusiveTouch = YES;
    }
    return self;
}

@end
