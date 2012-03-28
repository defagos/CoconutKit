//
//  UIResponder+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIResponder+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"

HLSLinkCategory(UIResponder_HLSExtensions)

static UIResponder *s_currentFirstResponder = nil;           // weak ref to the current first responder

// Original implementations of the methods we swizzle
static void (*s_UIResponder__becomeFirstResponder_Imp)(id, SEL) = NULL;
static void (*s_UIResponder__resignFirstResponder_Imp)(id, SEL) = NULL;

@interface UIResponder (HLSExtensionsPrivate)

- (void)swizzledBecomeFirstResponder;
- (void)swizzledResignFirstResponder;

@end

@implementation UIResponder (HLSExtensions)

#pragma mark Class methods

+ (UIResponder *)currentFirstResponder
{
    return s_currentFirstResponder;
}

@end

@implementation UIResponder (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UIResponder__becomeFirstResponder_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                    @selector(becomeFirstResponder), 
                                                                                    @selector(swizzledBecomeFirstResponder));
    s_UIResponder__resignFirstResponder_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                    @selector(resignFirstResponder), 
                                                                                    @selector(swizzledResignFirstResponder));
}

#pragma mark Swizzled method implementations

- (void)swizzledBecomeFirstResponder
{
    s_currentFirstResponder = self;
    (*s_UIResponder__becomeFirstResponder_Imp)(self, @selector(becomeFirstResponder));
}

- (void)swizzledResignFirstResponder
{
    (*s_UIResponder__resignFirstResponder_Imp)(self, @selector(resignFirstResponder));
    if (self == s_currentFirstResponder) {
        s_currentFirstResponder = nil;
    }
}

@end
