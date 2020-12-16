//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UITextField+HLSViewBinding.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;
static void (*s_dealloc)(__unsafe_unretained id, SEL) = NULL;
static void (*s_setText)(id, SEL, id) = NULL;
static void (*s_didMoveToWindow)(id, SEL) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UITextField *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UITextField *self, SEL _cmd, NSCoder *aDecoder);
static void swizzle_dealloc(__unsafe_unretained UITextField *self, SEL _cmd);
static void swizzle_setText(UITextField *self, SEL _cmd, NSString *text);
static void swizzle_didMoveToWindow(UITextField *self, SEL _cmd);

@implementation UITextField (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(initWithFrame:), swizzle_initWithFrame, &s_initWithFrame);
    HLSSwizzleSelector(self, @selector(initWithCoder:), swizzle_initWithCoder, &s_initWithCoder);
    HLSSwizzleSelector(self, sel_getUid("dealloc"), swizzle_dealloc, &s_dealloc);
    HLSSwizzleSelector(self, @selector(setText:), swizzle_setText, &s_setText);
    
    // iOS 12: UITextField now implements -didMoveToWindow, without calling the parent implementation. Swizzle to fix
    // so that bindings at the UIView level can work.
    if (@available(iOS 12, *)) {
        HLSSwizzleSelector(self, @selector(didMoveToWindow), swizzle_didMoveToWindow, &s_didMoveToWindow);
    }
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (BOOL)canDisplayPlaceholder
{
    return YES;
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    self.text = value;
}

- (id)inputValueWithClass:(Class)inputClass
{
    return self.text;
}

#pragma mark Notification callbacks

- (void)hls_textFieldDidChange:(NSNotification *)notification
{
    [self check:YES update:YES withInputValue:self.text error:NULL];
}

@end

#pragma mark Static functions

static void commonInit(UITextField *self)
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hls_textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self];
}

static id swizzle_initWithFrame(UITextField *self, SEL _cmd, CGRect frame)
{
    if ((self = s_initWithFrame(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UITextField *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = s_initWithCoder(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

// Marked as __unsafe_unretained to avoid ARC inserting incorrect memory management calls leading to crashes for -dealloc
static void swizzle_dealloc(__unsafe_unretained UITextField *self, SEL _cmd)
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:self];
    
    s_dealloc(self, _cmd);
}

static void swizzle_setText(UITextField *self, SEL _cmd, NSString *text)
{
    s_setText(self, _cmd, text);
    
    [self check:YES update:YES withInputValue:text error:NULL];
}

static void swizzle_didMoveToWindow(UITextField *self, SEL _cmd)
{
    // Insert the missing superclass method call
    Class superclass = class_getSuperclass([UITextField class]);
    IMP superImp = class_getMethodImplementation(superclass, _cmd);
    ((void (*)(id, SEL))superImp)(self, _cmd);
    
    s_didMoveToWindow(self, _cmd);
}
