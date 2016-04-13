//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UISlider+HLSViewBinding.h"

#import "HLSRuntime.h"
#import <objc/message.h>

// Original implementation of the methods we swizzle
static void (*s_setValue_animated)(id, SEL, float, BOOL) = NULL;

// Swizzled method implementations
static void swizzle_setValue_animated(UISlider *self, SEL _cmd, float value, BOOL animated);

@implementation UISlider (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(setValue:animated:), swizzle_setValue_animated, &s_setValue_animated);
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    [self setValue:[value floatValue] animated:animated];
}

- (id)inputValueWithClass:(Class)inputClass
{
    return @(self.value);
}

@end

#pragma mark Static functions

static void swizzle_setValue_animated(UISlider *self, SEL _cmd, float value, BOOL animated)
{
    s_setValue_animated(self, _cmd, value, animated);
    
    [self check:YES update:YES withInputValue:@(value) error:NULL];
}
