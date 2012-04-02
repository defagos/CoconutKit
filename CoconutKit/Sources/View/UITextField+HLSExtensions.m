//
//  UITextField+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UITextField+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"

HLSLinkCategory(UITextField_HLSExtensions)

static UITextField *s_currentTextField = nil;           // weak ref to the current first responder

// Original implementations of the methods we swizzle
static void (*s_UITextField__becomeFirstResponder_Imp)(id, SEL) = NULL;
static void (*s_UITextField__resignFirstResponder_Imp)(id, SEL) = NULL;

@interface UITextField (HLSExtensionsPrivate)

- (void)swizzledBecomeFirstResponder;
- (void)swizzledResignFirstResponder;

@end

@implementation UITextField (HLSExtensions)

#pragma mark Class methods

+ (UITextField *)currentTextField
{
    return s_currentTextField;
}

@end

@implementation UITextField (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UITextField__becomeFirstResponder_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                    @selector(becomeFirstResponder), 
                                                                                    @selector(swizzledBecomeFirstResponder));
    s_UITextField__resignFirstResponder_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                    @selector(resignFirstResponder), 
                                                                                    @selector(swizzledResignFirstResponder));
}

#pragma mark Swizzled method implementations

- (void)swizzledBecomeFirstResponder
{
    s_currentTextField = self;
    (*s_UITextField__becomeFirstResponder_Imp)(self, @selector(becomeFirstResponder));
}

- (void)swizzledResignFirstResponder
{
    (*s_UITextField__resignFirstResponder_Imp)(self, @selector(resignFirstResponder));
    if (self == s_currentTextField) {
        s_currentTextField = nil;
    }
}

@end
