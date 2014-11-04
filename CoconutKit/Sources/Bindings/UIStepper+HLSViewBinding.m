//
//  UIStepper+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIStepper+HLSViewBinding.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_lockKey = &s_lockKey;

// Original implementation of the methods we swizzle
static void (*s_UIStepper__setValue_Imp)(id, SEL, double) = NULL;

// Swizzled method implementations
static void swizzled_UIStepper__setValue_Imp(UIStepper *self, SEL _cmd, double value);

@implementation UIStepper (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIStepper__setValue_Imp = (void (*)(id, SEL, double))hls_class_swizzleSelector(self,
                                                                                     @selector(setValue:),
                                                                                     (IMP)swizzled_UIStepper__setValue_Imp);
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    objc_setAssociatedObject(self, s_lockKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.value = [value doubleValue];
    objc_setAssociatedObject(self, s_lockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

- (id)displayedValue
{
    return @(self.value);
}

@end

#pragma mark Swizzled method implementations

static void swizzled_UIStepper__setValue_Imp(UIStepper *self, SEL _cmd, double value)
{
    (*s_UIStepper__setValue_Imp)(self, _cmd, value);
    
    if (! objc_getAssociatedObject(self, s_lockKey)) {
        [self checkAndUpdateModelWithDisplayedValue:@(value) error:NULL];
    }
}
