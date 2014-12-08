//
//  UITextView+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UITextView+HLSViewBinding.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;
static void (*s_dealloc)(__unsafe_unretained id, SEL) = NULL;
static void (*s_setText)(id, SEL, id) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UITextView *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UITextView *self, SEL _cmd, NSCoder *aDecoder);
static void swizzle_dealloc(__unsafe_unretained UITextView *self, SEL _cmd);
static void swizzle_setText(UITextField *self, SEL _cmd, NSString *text);

@implementation UITextView (HLSViewBindingImplementation)

#pragma mark Class methods

+ (void)load
{
    s_initWithFrame = (__typeof(s_initWithFrame))hls_class_swizzleSelector(self, @selector(initWithFrame:), (IMP)swizzle_initWithFrame);
    s_initWithCoder = (__typeof(s_initWithCoder))hls_class_swizzleSelector(self, @selector(initWithCoder:), (IMP)swizzle_initWithCoder);
    s_dealloc = (__typeof(s_dealloc))hls_class_swizzleSelector(self, sel_getUid("dealloc"), (IMP)swizzle_dealloc);
    s_setText = (__typeof(s_setText))hls_class_swizzleSelector(self, @selector(setText:), (IMP)swizzle_setText);
}

#pragma mark HLSViewBindingImplementation protocol implementation

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    self.text = value;
}

- (id)inputValueWithClass:(Class)inputClass
{
    return self.text;
}

#pragma mark Notification callbacks

- (void)textViewDidChange:(NSNotification *)notification
{
    [self check:YES update:YES withInputValue:self.text error:NULL];
}

@end

#pragma mark Static functions

static void commonInit(UITextView *self)
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

static id swizzle_initWithFrame(UITextView *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_initWithFrame)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UITextView *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_initWithCoder)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}

// Marked as __unsafe_unretained to avoid ARC inserting incorrect memory management calls leading to crashes for -dealloc
static void swizzle_dealloc(__unsafe_unretained UITextView *self, SEL _cmd)
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    (*s_dealloc)(self, _cmd);
}

static void swizzle_setText(UITextField *self, SEL _cmd, NSString *text)
{
    (*s_setText)(self, _cmd, text);
    
    [self check:YES update:YES withInputValue:text error:NULL];
}

