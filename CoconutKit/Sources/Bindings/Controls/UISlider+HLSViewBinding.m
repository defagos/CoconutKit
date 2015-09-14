//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UISlider+HLSViewBinding.h"

#import "HLSRuntime.h"
#import <objc/message.h>

// Original implementation of the methods we swizzle
static void (*s_didMoveToWindow)(id, SEL) = NULL;
static void (*s_setValue_animated)(id, SEL, float, BOOL) = NULL;

// Swizzled method implementations
static void swizzle_didMoveToWindow(UISlider *self, SEL _cmd);
static void swizzle_setValue_animated(UISlider *self, SEL _cmd, float value, BOOL animated);

@implementation UISlider (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    // Binding implementation resolve bindings at the latest moment, when -didMoveToWindow is called, using swizzling.
    // Prior to iOS 7.1, -[UISlider didMoveToWindow] implementation failed to call the super method counterpart. The
    // -[UISlider didMoveToWindow] method implementation has been removed starting with iOS 7.1, which fixes this
    // issue. On iOS 7.0 and below, though, we must inject a fix so that the call chain is the expected one
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_1) {
        HLSSwizzleSelector(self, @selector(didMoveToWindow), swizzle_didMoveToWindow, &s_didMoveToWindow);
    }
    
    HLSSwizzleSelector(self, @selector(setValue:animated:), swizzle_setValue_animated, &s_setValue_animated);
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    [self setValue:[value floatValue] animated:animated];
}

- (id)inputValueWithClass:(Class)inputClass
{
    return @(self.value);
}

@end

#pragma mark Static functions

static void swizzle_didMoveToWindow(UISlider *self, SEL _cmd)
{
    // Fix missing call to the super method
    struct objc_super super = {
        .receiver = self,
        .super_class = class_getSuperclass([UISlider class])
    };
    
    // Cast the call to objc_msgSendSuper appropriately
    id (*objc_msgSendSuper_typed)(struct objc_super *, SEL) = (void *)&objc_msgSendSuper;
    objc_msgSendSuper_typed(&super, _cmd);
    
    s_didMoveToWindow(self, _cmd);
}

static void swizzle_setValue_animated(UISlider *self, SEL _cmd, float value, BOOL animated)
{
    s_setValue_animated(self, _cmd, value, animated);
    
    [self check:YES update:YES withInputValue:@(value) error:NULL];
}
