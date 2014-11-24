//
//  UISwitch+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UISwitch+HLSViewBinding.h"

#import "HLSRuntime.h"
#import "UIView+HLSViewBinding.h"

// Original implementation of the methods we swizzle
static id (*s_UISwitch__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UISwitch__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UISwitch__setOn_animated_Imp)(id, SEL, BOOL, BOOL) = NULL;

// Swizzled method implementations
static id swizzled_UISwitch__initWithFrame_Imp(UISwitch *self, SEL _cmd, CGRect frame);
static id swizzled_UISwitch__initWithCoder_Imp(UISwitch *self, SEL _cmd, NSCoder *aDecoder);
static void swizzled_UISwitch__setOn_animated_Imp(UISwitch *self, SEL _cmd, BOOL on, BOOL animated);

@implementation UISwitch (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    s_UISwitch__initWithFrame_Imp = (id (*)(id, SEL, CGRect))hls_class_swizzleSelector(self,
                                                                                       @selector(initWithFrame:),
                                                                                       (IMP)swizzled_UISwitch__initWithFrame_Imp);
    s_UISwitch__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                   @selector(initWithCoder:),
                                                                                   (IMP)swizzled_UISwitch__initWithCoder_Imp);
    s_UISwitch__setOn_animated_Imp = (void (*)(id, SEL, BOOL, BOOL))hls_class_swizzleSelector(self,
                                                                                              @selector(setOn:animated:),
                                                                                              (IMP)swizzled_UISwitch__setOn_animated_Imp);
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    [self setOn:[value boolValue] animated:animated];
}

- (id)inputValueWithClass:(Class)inputClass
{
    return @(self.on);
}

#pragma mark Actions

- (void)stateDidChange:(id)sender
{
    [self check:YES update:YES withInputValue:@(self.on) error:NULL];
}

@end

#pragma mark Static functions

// Neither -setOn:animated, nor -setOn: are called when the switch is changed interactively. To intercept those
// events, we need to add an action for UIControlEventValueChanged
static void commonInit(UISwitch *self)
{
    [self addTarget:self action:@selector(stateDidChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark Swizzled method implementations

static id swizzled_UISwitch__initWithFrame_Imp(UISwitch *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UISwitch__initWithFrame_Imp)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzled_UISwitch__initWithCoder_Imp(UISwitch *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UISwitch__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

static void swizzled_UISwitch__setOn_animated_Imp(UISwitch *self, SEL _cmd, BOOL on, BOOL animated)
{
    (*s_UISwitch__setOn_animated_Imp)(self, _cmd, on, animated);
    
    [self check:YES update:YES withInputValue:@(on) error:NULL];
}
