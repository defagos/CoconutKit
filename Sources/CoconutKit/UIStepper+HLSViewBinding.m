//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIStepper+HLSViewBinding.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static void (*s_setValue)(id, SEL, double) = NULL;

// Swizzled method implementations
static void swizzle_setValue(UIStepper *self, SEL _cmd, double value);

@implementation UIStepper (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(setValue:), swizzle_setValue, &s_setValue);
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    self.value = [value doubleValue];
}

- (id)inputValueWithClass:(Class)inputClass
{
    return @(self.value);
}

@end

#pragma mark Swizzled method implementations

static void swizzle_setValue(UIStepper *self, SEL _cmd, double value)
{
    s_setValue(self, _cmd, value);
    
    [self check:YES update:YES withInputValue:@(value) error:NULL];
}
