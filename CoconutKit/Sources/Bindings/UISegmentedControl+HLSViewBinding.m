//
//  UISegmentedControl+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 29/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UISegmentedControl+HLSViewBinding.h"

#import "HLSRuntime.h"
#import "UIView+HLSViewBinding.h"

// Associated object keys
static void *s_lockKey = &s_lockKey;

// Original implementation of the methods we swizzle
static id (*s_UISegmentedControl__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UISegmentedControl__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UISegmentedControl__setSelectedSegmentIndex_Imp)(id, SEL, NSInteger) = NULL;

// Swizzled method implementations
static id swizzled_UISegmentedControl__initWithFrame_Imp(UISegmentedControl *self, SEL _cmd, CGRect frame);
static id swizzled_UISegmentedControl__initWithCoder_Imp(UISegmentedControl *self, SEL _cmd, NSCoder *aDecoder);
static void swizzled_UISegmentedControl__setSelectedSegmentIndex_Imp(UISegmentedControl *self, SEL _cmd, NSInteger selectedSegmentIndex);

@implementation UISegmentedControl (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    s_UISegmentedControl__initWithFrame_Imp = (id (*)(id, SEL, CGRect))hls_class_swizzleSelector(self,
                                                                                                 @selector(initWithFrame:),
                                                                                                 (IMP)swizzled_UISegmentedControl__initWithFrame_Imp);
    s_UISegmentedControl__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                             @selector(initWithCoder:),
                                                                                             (IMP)swizzled_UISegmentedControl__initWithCoder_Imp);
    s_UISegmentedControl__setSelectedSegmentIndex_Imp = (void (*)(id, SEL, NSInteger))hls_class_swizzleSelector(self,
                                                                                                                @selector(setSelectedSegmentIndex:),
                                                                                                                (IMP)swizzled_UISegmentedControl__setSelectedSegmentIndex_Imp);
    
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    objc_setAssociatedObject(self, s_lockKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.selectedSegmentIndex = [value integerValue];
    objc_setAssociatedObject(self, s_lockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

- (id)displayedValue
{
    return @(self.selectedSegmentIndex);
}

#pragma mark Actions

- (void)boundValueDidChange:(id)sender
{
    id displayedValue = @(self.selectedSegmentIndex);
    [self checkAndUpdateModelWithDisplayedValue:displayedValue error:NULL];
}

@end

#pragma mark Static functions

// Neither -setOn:animated, nor -setOn: are called when the switch is changed interactively. To intercept those
// events, we need to add an action for UIControlEventValueChanged
static void commonInit(UISegmentedControl *self)
{
    [self addTarget:self action:@selector(boundValueDidChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark Swizzled method implementations

static id swizzled_UISegmentedControl__initWithFrame_Imp(UISegmentedControl *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UISegmentedControl__initWithFrame_Imp)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;

}

static id swizzled_UISegmentedControl__initWithCoder_Imp(UISegmentedControl *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UISegmentedControl__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

static void swizzled_UISegmentedControl__setSelectedSegmentIndex_Imp(UISegmentedControl *self, SEL _cmd, NSInteger selectedSegmentIndex)
{
    (*s_UISegmentedControl__setSelectedSegmentIndex_Imp)(self, _cmd, selectedSegmentIndex);
    
    if (! objc_getAssociatedObject(self, s_lockKey)) {
        id displayedValue = @(selectedSegmentIndex);
        [self checkAndUpdateModelWithDisplayedValue:displayedValue error:NULL];
    }
}
