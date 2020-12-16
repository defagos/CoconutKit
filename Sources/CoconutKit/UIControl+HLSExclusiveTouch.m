//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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
    HLSSwizzleSelector(self, @selector(initWithFrame:), swizzle_initWithFrame, &s_initWithFrame);
    HLSSwizzleSelector(self, @selector(initWithCoder:), swizzle_initWithCoder, &s_initWithCoder);
    
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
    if ((self = s_initWithFrame(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UIControl *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = s_initWithCoder(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}
