//
//  UITextView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 02.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UITextView+HLSExtensions.h"

#import "HLSRuntime.h"

static UITextView *s_currentTextView = nil;           // weak ref to the current first responder

// Original implementation of the methods we swizzle
static void (*s_UITextView__becomeFirstResponder_Imp)(id, SEL) = NULL;
static void (*s_UITextView__resignFirstResponder_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static void swizzled_UITextView__becomeFirstResponder_Imp(UITextView *self, SEL _cmd);
static void swizzled_UITextView__resignFirstResponder_Imp(UITextView *self, SEL _cmd);

@implementation UITextView (HLSExtensions)

#pragma mark Class methods

+ (UITextView *)currentTextView
{
    return s_currentTextView;
}

@end

@implementation UITextView (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UITextView__becomeFirstResponder_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                   @selector(becomeFirstResponder), 
                                                                                   (IMP)swizzled_UITextView__becomeFirstResponder_Imp);
    s_UITextView__resignFirstResponder_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                   @selector(resignFirstResponder), 
                                                                                   (IMP)swizzled_UITextView__resignFirstResponder_Imp);
}

@end

#pragma mark Swizzled method implementations

static void swizzled_UITextView__becomeFirstResponder_Imp(UITextView *self, SEL _cmd)
{
    s_currentTextView = self;
    (*s_UITextView__becomeFirstResponder_Imp)(self, _cmd);
}

static void swizzled_UITextView__resignFirstResponder_Imp(UITextView *self, SEL _cmd)
{
    (*s_UITextView__resignFirstResponder_Imp)(self, _cmd);
    if (self == s_currentTextView) {
        s_currentTextView = nil;
    }
}

