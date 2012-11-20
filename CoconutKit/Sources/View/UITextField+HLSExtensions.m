//
//  UITextField+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UITextField+HLSExtensions.h"

#import "HLSRuntime.h"

static UITextField *s_currentTextField = nil;           // weak ref to the current first responder

// Original implementation of the methods we swizzle
static BOOL (*s_UITextField__becomeFirstResponder_Imp)(id, SEL) = NULL;
static BOOL (*s_UITextField__resignFirstResponder_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzled_UITextField__becomeFirstResponder_Imp(UITextField *self, SEL _cmd);
static BOOL swizzled_UITextField__resignFirstResponder_Imp(UITextField *self, SEL _cmd);

@implementation UITextField (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    s_UITextField__becomeFirstResponder_Imp = (BOOL (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                    @selector(becomeFirstResponder), 
                                                                                    (IMP)swizzled_UITextField__becomeFirstResponder_Imp);
    s_UITextField__resignFirstResponder_Imp = (BOOL (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                    @selector(resignFirstResponder), 
                                                                                    (IMP)swizzled_UITextField__resignFirstResponder_Imp);
}

+ (UITextField *)currentTextField
{
    return s_currentTextField;
}

@end

#pragma mark Swizzled method implementations

static BOOL swizzled_UITextField__becomeFirstResponder_Imp(UITextField *self, SEL _cmd)
{
    s_currentTextField = self;
    return (*s_UITextField__becomeFirstResponder_Imp)(self, _cmd);
}

static BOOL swizzled_UITextField__resignFirstResponder_Imp(UITextField *self, SEL _cmd)
{
    BOOL result = (*s_UITextField__resignFirstResponder_Imp)(self, _cmd);
    if (self == s_currentTextField) {
        s_currentTextField = nil;
    }
    return result;
}
