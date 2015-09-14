//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UISwitch+HLSViewBinding.h"

#import "HLSRuntime.h"
#import "UIView+HLSViewBinding.h"

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;
static void (*s_setOn_animated)(id, SEL, BOOL, BOOL) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UISwitch *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UISwitch *self, SEL _cmd, NSCoder *aDecoder);
static void swizzle_setOn_animated(UISwitch *self, SEL _cmd, BOOL on, BOOL animated);

@implementation UISwitch (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(initWithFrame:), swizzle_initWithFrame, &s_initWithFrame);
    HLSSwizzleSelector(self, @selector(initWithCoder:), swizzle_initWithCoder, &s_initWithCoder);
    HLSSwizzleSelector(self, @selector(setOn:animated:), swizzle_setOn_animated, &s_setOn_animated);
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

static id swizzle_initWithFrame(UISwitch *self, SEL _cmd, CGRect frame)
{
    if ((self = s_initWithFrame(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UISwitch *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = s_initWithCoder(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

static void swizzle_setOn_animated(UISwitch *self, SEL _cmd, BOOL on, BOOL animated)
{
    s_setOn_animated(self, _cmd, on, animated);
    
    [self check:YES update:YES withInputValue:@(on) error:NULL];
}
