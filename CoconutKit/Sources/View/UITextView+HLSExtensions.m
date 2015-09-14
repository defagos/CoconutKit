//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UITextView+HLSExtensions.h"

#import "HLSRuntime.h"
#import "HLSViewTouchDetector.h"

// Associated object keys
static void *s_touchDetectorKey = &s_touchDetectorKey;

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UITextView *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UITextView *self, SEL _cmd, NSCoder *aDecoder);

@interface UITextView (HLSExtensionsPrivate)

@property (nonatomic, strong) HLSViewTouchDetector *touchDetector;

@end

@implementation UITextView (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(initWithFrame:), swizzle_initWithFrame, &s_initWithFrame);
    HLSSwizzleSelector(self, @selector(initWithCoder:), swizzle_initWithCoder, &s_initWithCoder);
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

static id swizzle_initWithFrame(UITextView *self, SEL _cmd, CGRect frame)
{
    if ((self = s_initWithFrame(self, _cmd, frame))) {
        commonInit(self);
    }
    return self;
}

static id swizzle_initWithCoder(UITextView *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = s_initWithCoder(self, _cmd, aDecoder))) {
        commonInit(self);
    }
    return self;
}
