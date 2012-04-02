//
//  UITextView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 02.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UITextView+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"

HLSLinkCategory(UITextView_HLSExtensions)

static UITextView *s_currentTextView = nil;           // weak ref to the current first responder

// Original implementations of the methods we swizzle
static void (*s_UITextView__becomeFirstResponder_Imp)(id, SEL) = NULL;
static void (*s_UITextView__resignFirstResponder_Imp)(id, SEL) = NULL;

@interface UITextView (HLSExtensionsPrivate)

- (void)swizzledBecomeFirstResponder;
- (void)swizzledResignFirstResponder;

@end

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
                                                                                   @selector(swizzledBecomeFirstResponder));
    s_UITextView__resignFirstResponder_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                   @selector(resignFirstResponder), 
                                                                                   @selector(swizzledResignFirstResponder));
}

#pragma mark Swizzled method implementations

- (void)swizzledBecomeFirstResponder
{
    s_currentTextView = self;
    (*s_UITextView__becomeFirstResponder_Imp)(self, @selector(becomeFirstResponder));
}

- (void)swizzledResignFirstResponder
{
    (*s_UITextView__resignFirstResponder_Imp)(self, @selector(resignFirstResponder));
    if (self == s_currentTextView) {
        s_currentTextView = nil;
    }
}

@end
