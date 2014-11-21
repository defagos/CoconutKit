//
//  UITextField+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UITextField+HLSExtensions.h"

#import "HLSRuntime.h"
#import "HLSViewTouchDetector.h"

// Associated object keys
static void *s_touchDetectorKey = &s_touchDetectorKey;

// Original implementation of the methods we swizzle
static id (*s_UITextField__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UITextField__initWithCoder_Imp)(id, SEL, id) = NULL;

// Swizzled method implementations
static id swizzled_UITextField__initWithFrame_Imp(UITextField *self, SEL _cmd, CGRect frame);
static id swizzled_UITextField__initWithCoder_Imp(UITextField *self, SEL _cmd, NSCoder *aDecoder);

@interface UITextField (HLSExtensionsPrivate)

@property (nonatomic, strong) HLSViewTouchDetector *touchDetector;

@end

@implementation UITextField (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    s_UITextField__initWithFrame_Imp = (id (*)(id, SEL, CGRect))hls_class_swizzleSelector(self,
                                                                                          @selector(initWithFrame:),
                                                                                          (IMP)swizzled_UITextField__initWithFrame_Imp);
    s_UITextField__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                      @selector(initWithCoder:),
                                                                                      (IMP)swizzled_UITextField__initWithCoder_Imp);
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

@implementation UITextField (HLSExtensionsPrivate)

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

static void commonInit(UITextField *self)
{
    self.touchDetector = [[HLSViewTouchDetector alloc] initWithView:self
                                              beginNotificationName:UITextFieldTextDidBeginEditingNotification
                                                endNotificationName:UITextFieldTextDidEndEditingNotification];
}

#pragma mark Swizzled method implementations

static id swizzled_UITextField__initWithFrame_Imp(UITextField *self, SEL _cmd, CGRect frame)
{
    if ((self = (*s_UITextField__initWithFrame_Imp)(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzled_UITextField__initWithCoder_Imp(UITextField *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UITextField__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}
