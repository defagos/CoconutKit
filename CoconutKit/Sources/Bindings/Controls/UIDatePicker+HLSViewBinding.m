//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIDatePicker+HLSViewBinding.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;
static void (*s_setDate)(id, SEL, id) = NULL;
static void (*s_setDate_animated)(id, SEL, id, BOOL) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UIDatePicker *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UIDatePicker *self, SEL _cmd, NSCoder *aDecoder);
static void swizzle_setDate(UIDatePicker *self, SEL _cmd, NSDate *date);
static void swizzle_setDate_animated(UIDatePicker *self, SEL _cmd, NSDate *date, BOOL animated);

@implementation UIDatePicker (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(initWithFrame:), swizzle_initWithFrame, &s_initWithFrame);
    HLSSwizzleSelector(self, @selector(initWithCoder:), swizzle_initWithCoder, &s_initWithCoder);
    HLSSwizzleSelector(self, @selector(setDate:), swizzle_setDate, &s_setDate);
    HLSSwizzleSelector(self, @selector(setDate:animated:), swizzle_setDate_animated, &s_setDate_animated);
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

static id swizzle_initWithFrame(UIDatePicker *self, SEL _cmd, CGRect frame)
{
    if ((self = s_initWithFrame(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UIDatePicker *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = s_initWithCoder(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

static void swizzle_setDate(UIDatePicker *self, SEL _cmd, NSDate *date)
{
    s_setDate(self, _cmd, date);
    
    [self check:YES update:YES withInputValue:date error:NULL];
}

static void swizzle_setDate_animated(UIDatePicker *self, SEL _cmd, NSDate *date, BOOL animated)
{
    s_setDate_animated(self, _cmd, date, animated);
    
    [self check:YES update:YES withInputValue:date error:NULL];
}
