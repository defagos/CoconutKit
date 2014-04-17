//
//  UISwitch+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UISwitch+HLSViewBinding.h"

#import "HLSRuntime.h"
#import "UIView+HLSViewBinding.h"

// Original implementation of the methods we swizzle
static void (*s_UISwitch__setOn_animated_Imp)(id, SEL, BOOL, BOOL) = NULL;

// Swizzled method implementations
static void swizzled_UISwitch__setOn_animated_Imp(UISwitch *self, SEL _cmd, BOOL on, BOOL animated);

@implementation UISwitch (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UISwitch__setOn_animated_Imp = (void (*)(id, SEL, BOOL, BOOL))hls_class_swizzleSelector(self,
                                                                                              @selector(setOn:animated:),
                                                                                              (IMP)swizzled_UISwitch__setOn_animated_Imp);
}

#pragma mark HLSViewBinding protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    self.on = [value boolValue];
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

- (id)displayedValue
{
    return @(self.on);
}

@end

#pragma mark Swizzled method implementations

static void swizzled_UISwitch__setOn_animated_Imp(UISwitch *self, SEL _cmd, BOOL on, BOOL animated)
{
    (*s_UISwitch__setOn_animated_Imp)(self, _cmd, on, animated);
    
    id displayedValue = @(on);
    [self checkAndUpdateModelWithDisplayedValue:displayedValue error:NULL];
}
