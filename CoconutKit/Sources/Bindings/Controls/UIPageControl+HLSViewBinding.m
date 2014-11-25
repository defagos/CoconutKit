//
//  UIPageControl+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIPageControl+HLSViewBinding.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_UIPageControl__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UIPageControl__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UIPageControl__setCurrentPage_Imp)(id, SEL, NSInteger) = NULL;

// Swizzled method implementations
static id swizzled_UIPageControl__initWithFrame_Imp(UIPageControl *self, SEL _cmd, CGRect frame);
static id swizzled_UIPageControl__initWithCoder_Imp(UIPageControl *self, SEL _cmd, NSCoder *aDecoder);
static void swizzled_UIPageControl__setCurrentPage_Imp(UIPageControl *self, SEL _cmd, NSInteger currentPage);

@implementation UIPageControl (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIPageControl__initWithFrame_Imp = (id (*)(id, SEL, CGRect))hls_class_swizzleSelector(self,
                                                                                            @selector(initWithFrame:),
                                                                                            (IMP)swizzled_UIPageControl__initWithFrame_Imp);
    s_UIPageControl__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                        @selector(initWithCoder:),
                                                                                        (IMP)swizzled_UIPageControl__initWithCoder_Imp);
    s_UIPageControl__setCurrentPage_Imp = (void (*)(id, SEL, NSInteger))hls_class_swizzleSelector(self,
                                                                                                  @selector(setCurrentPage:),
                                                                                                  (IMP)swizzled_UIPageControl__setCurrentPage_Imp);
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    self.currentPage = [value integerValue];
}

- (id)inputValueWithClass:(Class)inputClass
{
    return @(self.currentPage);
}

#pragma mark Actions

- (void)currentPageDidChange:(id)sender
{
    [self check:YES update:YES withInputValue:@(self.currentPage) error:NULL];
}

@end

#pragma mark Static functions

// Neither -setOn:animated, nor -setOn: are called when the switch is changed interactively. To intercept those
// events, we need to add an action for UIControlEventValueChanged
static void commonInit(UIPageControl *self)
{
    [self addTarget:self action:@selector(currentPageDidChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark Swizzled method implementations

static id swizzled_UIPageControl__initWithFrame_Imp(UIPageControl *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UIPageControl__initWithFrame_Imp)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzled_UIPageControl__initWithCoder_Imp(UIPageControl *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UIPageControl__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

static void swizzled_UIPageControl__setCurrentPage_Imp(UIPageControl *self, SEL _cmd, NSInteger currentPage)
{
    (*s_UIPageControl__setCurrentPage_Imp)(self, _cmd, currentPage);
    
    [self check:YES update:YES withInputValue:@(currentPage) error:NULL];
}
