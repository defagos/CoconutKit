//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIPageControl+HLSViewBinding.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;
static void (*s_setCurrentPage)(id, SEL, NSInteger) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UIPageControl *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UIPageControl *self, SEL _cmd, NSCoder *aDecoder);
static void swizzle_setCurrentPage(UIPageControl *self, SEL _cmd, NSInteger currentPage);

@implementation UIPageControl (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(initWithFrame:), swizzle_initWithFrame, &s_initWithFrame);
    HLSSwizzleSelector(self, @selector(initWithCoder:), swizzle_initWithCoder, &s_initWithCoder);
    HLSSwizzleSelector(self, @selector(setCurrentPage:), swizzle_setCurrentPage, &s_setCurrentPage);
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

static id swizzle_initWithFrame(UIPageControl *self, SEL _cmd, CGRect frame)
{
    if ((self = s_initWithFrame(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UIPageControl *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = s_initWithCoder(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

static void swizzle_setCurrentPage(UIPageControl *self, SEL _cmd, NSInteger currentPage)
{
    s_setCurrentPage(self, _cmd, currentPage);
    
    [self check:YES update:YES withInputValue:@(currentPage) error:NULL];
}
