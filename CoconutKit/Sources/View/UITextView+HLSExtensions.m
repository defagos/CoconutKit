//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UITextView+HLSExtensions.h"

#import "HLSRuntime.h"
#import "HLSViewTouchDetector.h"
#import "UIView+HLSExtensions.h"

// Associated object keys
static void *s_touchDetectorKey = &s_touchDetectorKey;

// Original implementation of the methods we swizzle
static id (*s_initWithFrame)(id, SEL, CGRect) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;

// Swizzled method implementations
static id swizzle_initWithFrame(UITextView *self, SEL _cmd, CGRect frame);
static id swizzle_initWithCoder(UITextView *self, SEL _cmd, NSCoder *aDecoder);

@interface UITextView (HLSExtensionsPrivate)

@property (nonatomic) HLSViewTouchDetector *touchDetector;

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

#pragma mark HLSKeyboardAvodingBehavior protocol implementation

- (void)locateFocusRectWithCompletionBlock:(HLSFocusRectCompletionBlock)completionBlock
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Locate the first view leaf and focus on it. Can be the blinking cursor or part of the selection view
        UIView *cursorView = self;
        while ([cursorView.subviews count] != 0) {
            cursorView = [cursorView.subviews firstObject];
        }
        
        static const CGFloat HLSCursorVisibilityMargin = 10.f;
        CGRect cursorViewFrame = [self convertRect:cursorView.bounds fromView:cursorView];
        CGRect enlargedCursorViewFrame = CGRectMake(CGRectGetMinX(cursorViewFrame) - HLSCursorVisibilityMargin,
                                                    CGRectGetMinY(cursorViewFrame) - HLSCursorVisibilityMargin,
                                                    CGRectGetWidth(cursorViewFrame) + 2 * HLSCursorVisibilityMargin,
                                                    CGRectGetHeight(cursorViewFrame) + 2 * HLSCursorVisibilityMargin);
        completionBlock ? completionBlock(enlargedCursorViewFrame) : nil;
    });
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
    hls_setAssociatedObject(self, s_touchDetectorKey, touchDetector, HLS_ASSOCIATION_STRONG_NONATOMIC);
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
