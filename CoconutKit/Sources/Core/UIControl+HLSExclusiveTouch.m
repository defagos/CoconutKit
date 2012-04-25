//
//  UIControl+HLSExclusiveTouch.m
//  CoconutKit
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

// Swizzled method implementations
static id swizzled_UIControl__initWithFrame_Imp(UIControl *self, SEL _cmd, CGRect frame);
static id swizzled_UIControl__initWithCoder_Imp(UIControl *self, SEL _cmd, NSCoder *aDecoder);

@implementation UIControl (HLSExclusiveTouch)

#pragma mark Class methods

+ (void)injectExclusiveTouch
{
    if (m_injected) {
        HLSLoggerInfo(@"Exclusive touch already injected");
        return;
    }
    
    // Swizzle the original implementations (keep a hand on them)
    s_UIControl__initWithFrame_Imp = (id (*)(id, SEL, CGRect))HLSSwizzleSelector(self, 
                                                                                 @selector(initWithFrame:), 
                                                                                 (IMP)swizzled_UIControl__initWithFrame_Imp);
    s_UIControl__initWithCoder_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector(self, 
                                                                             @selector(initWithCoder:), 
                                                                             (IMP)swizzled_UIControl__initWithCoder_Imp);
    
    m_injected = YES;
}

@end

#pragma mark Swizzled method implementations

static id swizzled_UIControl__initWithFrame_Imp(UIControl *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UIControl__initWithFrame_Imp)(self, _cmd, frame))) {
        self.exclusiveTouch = YES;
    }
    return self;
}

static id swizzled_UIControl__initWithCoder_Imp(UIControl *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UIControl__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        self.exclusiveTouch = YES;
    }
    return self;
}
