//
//  UIResponder+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 07.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIResponder+HLSExtensions.h"

#import "HLSRuntime.h"
#import "UIScrollView+HLSExtensions.h"

// Original implementation of the methods we swizzle
static BOOL (*s_UIResponder_becomeFirstResponder)(id, SEL) = NULL;
static BOOL (*s_UIResponder_resignFirstResponder)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzled_UIResponder__becomeFirstResponder_Imp(UIResponder *self, SEL _cmd);
static BOOL swizzled_UIResponder__resignFirstResponder_Imp(UIResponder *self, SEL _cmd);

@implementation UIResponder (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    s_UIResponder_becomeFirstResponder = (BOOL (*)(id, SEL))HLSSwizzleSelector(self, @selector(becomeFirstResponder), (IMP)swizzled_UIResponder__becomeFirstResponder_Imp);
    s_UIResponder_resignFirstResponder = (BOOL (*)(id, SEL))HLSSwizzleSelector(self, @selector(resignFirstResponder), (IMP)swizzled_UIResponder__resignFirstResponder_Imp);
}

@end

#pragma mark Swizzled method implementations

static BOOL swizzled_UIResponder__becomeFirstResponder_Imp(UIResponder *self, SEL _cmd)
{
    BOOL result = (*s_UIResponder_becomeFirstResponder)(self, _cmd);
    
    if (! [self isKindOfClass:[UIView class]]) {
        return result;
    }
    UIView *view = (UIView *)self;
    
    UIView *topParentAvoidingKeyboardingScrollView = nil;
    UIView *parentView = view.superview;
    while (parentView) {
        if ([parentView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollParentView = (UIScrollView *)parentView;
            if (scrollParentView.avoidingKeyboard) {
                topParentAvoidingKeyboardingScrollView = scrollParentView;
            }
        }
        parentView = parentView.superview;
    }
    
    if (! topParentAvoidingKeyboardingScrollView) {
        return result;
    }
    
    // TODO: Scroll to make visible
    
    return result;
}

static BOOL swizzled_UIResponder__resignFirstResponder_Imp(UIResponder *self, SEL _cmd)
{
    return (*s_UIResponder_resignFirstResponder)(self, _cmd);
}
