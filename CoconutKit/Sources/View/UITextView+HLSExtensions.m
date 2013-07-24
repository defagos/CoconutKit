//
//  UITextView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 02.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UITextView+HLSExtensions.h"

#import "HLSRuntime.h"
#import "HLSViewTouchDetector.h"

static UITextView *s_currentTextView = nil;           // weak ref to the current first responder

// Associated object keys
static void *s_touchDetectorKey = &s_touchDetectorKey;

// Original implementation of the methods we swizzle
static id (*s_UITextView__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UITextView__initWithCoder_Imp)(id, SEL, id) = NULL;
static BOOL (*s_UITextView__becomeFirstResponder_Imp)(id, SEL) = NULL;
static BOOL (*s_UITextView__resignFirstResponder_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static id swizzled_UITextView__initWithFrame_Imp(UITextView *self, SEL _cmd, CGRect frame);
static id swizzled_UITextView__initWithCoder_Imp(UITextView *self, SEL _cmd, NSCoder *aDecoder);
static BOOL swizzled_UITextView__becomeFirstResponder_Imp(UITextView *self, SEL _cmd);
static BOOL swizzled_UITextView__resignFirstResponder_Imp(UITextView *self, SEL _cmd);

@interface UITextView (HLSExtensionsPrivate)

@property (nonatomic, retain) HLSViewTouchDetector *touchDetector;

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
    s_UITextView__becomeFirstResponder_Imp = (BOOL (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                          @selector(becomeFirstResponder),
                                                                                          (IMP)swizzled_UITextView__becomeFirstResponder_Imp);
    s_UITextView__resignFirstResponder_Imp = (BOOL (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                          @selector(resignFirstResponder),
                                                                                          (IMP)swizzled_UITextView__resignFirstResponder_Imp);
}

+ (UITextView *)currentTextView
{
    return s_currentTextView;
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
    return objc_getAssociatedObject(self, s_touchDetectorKey);
}

- (void)setTouchDetector:(HLSViewTouchDetector *)touchDetector
{
    objc_setAssociatedObject(self, s_touchDetectorKey, touchDetector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark Common initialization

static void commonInit(UITextView *self)
{
    self.touchDetector = [[[HLSViewTouchDetector alloc] initWithView:self
                                               beginNotificationName:UITextViewTextDidBeginEditingNotification
                                                 endNotificationName:UITextViewTextDidEndEditingNotification] autorelease];
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

static BOOL swizzled_UITextView__becomeFirstResponder_Imp(UITextView *self, SEL _cmd)
{
    s_currentTextView = self;
    return (*s_UITextView__becomeFirstResponder_Imp)(self, _cmd);
}

static BOOL swizzled_UITextView__resignFirstResponder_Imp(UITextView *self, SEL _cmd)
{
    BOOL result = (*s_UITextView__resignFirstResponder_Imp)(self, _cmd);
    if (self == s_currentTextView) {
        s_currentTextView = nil;
    }
	return result;
}

