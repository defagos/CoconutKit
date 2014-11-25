//
//  UIDatePicker+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 05.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIDatePicker+HLSViewBinding.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_UIDatePicker__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UIDatePicker__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UIDatePicker__setDate_Imp)(id, SEL, id) = NULL;
static void (*s_UIDatePicker__setDate_animated_Imp)(id, SEL, id, BOOL) = NULL;

// Swizzled method implementations
static id swizzled_UIDatePicker__initWithFrame_Imp(UIDatePicker *self, SEL _cmd, CGRect frame);
static id swizzled_UIDatePicker__initWithCoder_Imp(UIDatePicker *self, SEL _cmd, NSCoder *aDecoder);
static void swizzled_UIDatePicker__setDate_Imp(UIDatePicker *self, SEL _cmd, NSDate *date);
static void swizzled_UIDatePicker__setDate_animated_Imp(UIDatePicker *self, SEL _cmd, NSDate *date, BOOL animated);

@implementation UIDatePicker (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIDatePicker__initWithFrame_Imp = (id (*)(id, SEL, CGRect))hls_class_swizzleSelector(self,
                                                                                           @selector(initWithFrame:),
                                                                                           (IMP)swizzled_UIDatePicker__initWithFrame_Imp);
    s_UIDatePicker__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                       @selector(initWithCoder:),
                                                                                       (IMP)swizzled_UIDatePicker__initWithCoder_Imp);
    
    // Both setters are independent, must swizzle both
    s_UIDatePicker__setDate_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                   @selector(setDate:),
                                                                                   (IMP)swizzled_UIDatePicker__setDate_Imp);
    s_UIDatePicker__setDate_animated_Imp = (void (*)(id, SEL, id, BOOL))hls_class_swizzleSelector(self,
                                                                                                  @selector(setDate:animated:),
                                                                                                  (IMP)swizzled_UIDatePicker__setDate_animated_Imp);
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSDate class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    // Setting nil crashes the picker. Since the picker shows the current date by default,
    // we do the same when the associated value is nil
    NSDate *date = value ?: [NSDate date];
    [self setDate:date animated:animated];
}

- (id)inputValueWithClass:(Class)inputClass
{
    return self.date;
}

#pragma mark Actions

- (IBAction)dateDidChange:(id)sender
{
    [self check:YES update:YES withInputValue:self.date error:NULL];
}

@end

#pragma mark Static functions

// Neither -setDate:animated, nor -setDate: are called when the switch is changed interactively. To intercept those
// events, we need to add an action for UIControlEventValueChanged
static void commonInit(UIDatePicker *self)
{
    [self addTarget:self action:@selector(dateDidChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark Static functions

static id swizzled_UIDatePicker__initWithFrame_Imp(UIDatePicker *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UIDatePicker__initWithFrame_Imp)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzled_UIDatePicker__initWithCoder_Imp(UIDatePicker *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UIDatePicker__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

static void swizzled_UIDatePicker__setDate_Imp(UIDatePicker *self, SEL _cmd, NSDate *date)
{
    (*s_UIDatePicker__setDate_Imp)(self, _cmd, date);
    
    [self check:YES update:YES withInputValue:date error:NULL];
}

static void swizzled_UIDatePicker__setDate_animated_Imp(UIDatePicker *self, SEL _cmd, NSDate *date, BOOL animated)
{
    (*s_UIDatePicker__setDate_animated_Imp)(self, _cmd, date, animated);
    
    [self check:YES update:YES withInputValue:date error:NULL];
}
