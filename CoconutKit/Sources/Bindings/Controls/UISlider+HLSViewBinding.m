//
//  UISlider+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 16/03/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UISlider+HLSViewBinding.h"

#import "HLSRuntime.h"
#import <objc/message.h>

// Original implementation of the methods we swizzle
static void (*s_UISlider__didMoveToWindow_Imp)(id, SEL) = NULL;
static void (*s_UISlider__setValue_animated_Imp)(id, SEL, float, BOOL) = NULL;

// Swizzled method implementations
static void swizzled_UISlider__didMoveToWindow_Imp(UISlider *self, SEL _cmd);
static void swizzled_UISlider__setValue_animated_Imp(UISlider *self, SEL _cmd, float value, BOOL animated);

@implementation UISlider (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    // Binding implementation resolve bindings at the latest moment, when -didMoveToWindow is called, using swizzling.
    // Prior to iOS 7.1, -[UISlider didMoveToWindow] implementation failed to call the super method counterpart. The
    // -[UISlider didMoveToWindow] method implementation has been removed starting with iOS 7.1, which fixes this
    // issue. On iOS 7.0 and below, though, we must inject a fix so that the call chain is the expected one
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_1) {
        s_UISlider__didMoveToWindow_Imp = (void (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                       @selector(didMoveToWindow),
                                                                                       (IMP)swizzled_UISlider__didMoveToWindow_Imp);
    }
    
    s_UISlider__setValue_animated_Imp = (void (*)(id, SEL, float, BOOL))hls_class_swizzleSelector(self,
                                                                                                  @selector(setValue:animated:),
                                                                                                  (IMP)swizzled_UISlider__setValue_animated_Imp);
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

static void swizzled_UISlider__didMoveToWindow_Imp(UISlider *self, SEL _cmd)
{
    // Fix missing call to the super method
    struct objc_super super = {
        .receiver = self,
        .super_class = class_getSuperclass([UISlider class])
    };
    
    // Cast the call to objc_msgSendSuper appropriately
    id (*objc_msgSendSuper_typed)(struct objc_super *, SEL) = (void *)&objc_msgSendSuper;
    objc_msgSendSuper_typed(&super, _cmd);
    
    (*s_UISlider__didMoveToWindow_Imp)(self, _cmd);
}

static void swizzled_UISlider__setValue_animated_Imp(UISlider *self, SEL _cmd, float value, BOOL animated)
{
    (*s_UISlider__setValue_animated_Imp)(self, _cmd, value, animated);
    
    [self check:YES update:YES withInputValue:@(value) error:NULL];
}
