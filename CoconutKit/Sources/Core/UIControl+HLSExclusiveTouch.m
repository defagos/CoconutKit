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
static id (*s_UIControl__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UIControl__initWithCoder_Imp)(id, SEL, id) = NULL;

// Swizzled method implementations
static id swizzled_UIControl__initWithFrame_Imp(UIControl *self, SEL _cmd, CGRect frame);
static id swizzled_UIControl__initWithCoder_Imp(UIControl *self, SEL _cmd, NSCoder *aDecoder);

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
    s_UIControl__initWithFrame_Imp = (id (*)(id, SEL, CGRect))hls_class_swizzleSelector(self,
                                                                                        @selector(initWithFrame:),
                                                                                        (IMP)swizzled_UIControl__initWithFrame_Imp);
    s_UIControl__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                    @selector(initWithCoder:),
                                                                                    (IMP)swizzled_UIControl__initWithCoder_Imp);
    
    s_injected = YES;
}

@end

#pragma mark Static functions

static void commonInit(UIControl *self)
{
    self.exclusiveTouch = YES;
}

static id swizzled_UIControl__initWithFrame_Imp(UIControl *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UIControl__initWithFrame_Imp)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzled_UIControl__initWithCoder_Imp(UIControl *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UIControl__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}
