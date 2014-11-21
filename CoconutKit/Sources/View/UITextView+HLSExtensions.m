//
//  UITextView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 02.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UITextView+HLSExtensions.h"

#import "HLSRuntime.h"
#import "HLSViewTouchDetector.h"

// Associated object keys
static void *s_touchDetectorKey = &s_touchDetectorKey;

// Original implementation of the methods we swizzle
static id (*s_UITextView__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UITextView__initWithCoder_Imp)(id, SEL, id) = NULL;

// Swizzled method implementations
static id swizzled_UITextView__initWithFrame_Imp(UITextView *self, SEL _cmd, CGRect frame);
static id swizzled_UITextView__initWithCoder_Imp(UITextView *self, SEL _cmd, NSCoder *aDecoder);

@interface UITextView (HLSExtensionsPrivate)

@property (nonatomic, strong) HLSViewTouchDetector *touchDetector;

@end

@implementation UITextView (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    s_UITextView__initWithFrame_Imp = (id (*)(id, SEL, CGRect))hls_class_swizzleSelector(self,
                                                                                         @selector(initWithFrame:),
                                                                                         (IMP)swizzled_UITextView__initWithFrame_Imp);
    s_UITextView__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                     @selector(initWithCoder:),
                                                                                     (IMP)swizzled_UITextView__initWithCoder_Imp);
}

#pragma mark Accessors and mutators

- (BOOL)isResigningFirstResponderOnTap
{
    return self.touchDetector.resigningFirstResponderOnTap;
}

- (void)setResigningFirstResponderOnTap:(BOOL)resigningFirstResponderOnTap
{
    self.touchDetector.resigningFirstResponderOnTap = resigningFirstResponderOnTap;
}

@end

@implementation UITextView (HLSExtensionsPrivate)

#pragma mark Accessors and mutators

- (HLSViewTouchDetector *)touchDetector
{
    return hls_getAssociatedObject(self, s_touchDetectorKey);
}

- (void)setTouchDetector:(HLSViewTouchDetector *)touchDetector
{
    hls_setAssociatedObject(self, s_touchDetectorKey, touchDetector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark Common initialization

static void commonInit(UITextView *self)
{
    self.touchDetector = [[HLSViewTouchDetector alloc] initWithView:self
                                              beginNotificationName:UITextViewTextDidBeginEditingNotification
                                                endNotificationName:UITextViewTextDidEndEditingNotification];
}

#pragma mark Swizzled method implementations

static id swizzled_UITextView__initWithFrame_Imp(UITextView *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UITextView__initWithFrame_Imp)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzled_UITextView__initWithCoder_Imp(UITextView *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UITextView__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}
