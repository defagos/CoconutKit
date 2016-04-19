//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIScrollView+HLSExtensions.h"

#import "HLSAssert.h"
#import "HLSKeyboardInformation.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UIView+HLSExtensions.h"
#import "UIWindow+HLSExtensions.h"

// Associated object keys
static void *s_synchronizedScrollViewsKey = &s_synchronizedScrollViewsKey;
static void *s_parallaxBouncesKey = &s_parallaxBouncesKey;
static void *s_avoidingKeyboardKey = &s_avoidingKeyboardKey;

// Original implementation of the methods we swizzle
static void (*s_setContentOffset)(id, SEL, CGPoint) = NULL;
static void (*s_willMoveToWindow)(id, SEL, id) = NULL;
static void (*s_layoutSubviews)(id, SEL) = NULL;

// Swizzled method implementations
static void swizzle_setContentOffset(UIScrollView *self, SEL _cmd, CGPoint contentOffset);
static void swizzle_willMoveToWindow(UIScrollView *self, SEL _cmd, UIWindow *window);
static void swizzle_layoutSubviews(UIScrollView *self, SEL _cmd);

static NSMutableSet<UIScrollView *> *s_adjustedScrollViews = nil;
static NSMutableDictionary<NSValue *, NSNumber *> *s_scrollViewOriginalBottomInsets = nil;
static NSMutableDictionary<NSValue *, NSNumber *> *s_scrollViewOriginalIndicatorBottomInsets = nil;

@interface UIScrollView (HLSExtensionsPrivate)

- (void)synchronizeScrolling;

@end

@implementation UIScrollView (HLSExtensions)

#pragma mark Accessors and mutators

- (BOOL)isAvoidingKeyboard
{
    return [hls_getAssociatedObject(self, s_avoidingKeyboardKey) boolValue];
}

- (void)setAvoidingKeyboard:(BOOL)avoidingKeyboard
{
    hls_setAssociatedObject(self, s_avoidingKeyboardKey, @(avoidingKeyboard), HLS_ASSOCIATION_STRONG_NONATOMIC);
}

#pragma mark Synchronizing scroll views

- (void)synchronizeWithScrollViews:(NSArray<UIScrollView *> *)scrollViews bounces:(BOOL)bounces
{
    NSParameterAssert(scrollViews);
    HLSAssertObjectsInEnumerationAreKindOfClass(scrollViews, UIScrollView);
    
    if ([scrollViews containsObject:self]) {
        HLSLoggerError(@"A scroll view cannot be synchronized with itself");
        return;
    }
    
    hls_setAssociatedObject(self, s_synchronizedScrollViewsKey, scrollViews, HLS_ASSOCIATION_STRONG_NONATOMIC);
    hls_setAssociatedObject(self, s_parallaxBouncesKey, @(bounces), HLS_ASSOCIATION_STRONG_NONATOMIC);
}

- (void)removeSynchronization
{
    hls_setAssociatedObject(self, s_synchronizedScrollViewsKey, nil, HLS_ASSOCIATION_STRONG_NONATOMIC);
    hls_setAssociatedObject(self, s_parallaxBouncesKey, nil, HLS_ASSOCIATION_STRONG_NONATOMIC);
}

@end

@implementation UIScrollView (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(setContentOffset:), swizzle_setContentOffset, &s_setContentOffset);
    HLSSwizzleSelector(self, @selector(willMoveToWindow:), swizzle_willMoveToWindow, &s_willMoveToWindow);
    HLSSwizzleSelector(self, @selector(layoutSubviews), swizzle_layoutSubviews, &s_layoutSubviews);
}

#pragma mark Scrolling synchronization

- (void)synchronizeScrolling
{
    NSArray<UIScrollView *> *synchronizedScrollViews = hls_getAssociatedObject(self, s_synchronizedScrollViewsKey);
    if (! synchronizedScrollViews) {
        return;
    }
    
    // Calculate the relative offset position (in [0; 1]) of the receiver
    CGFloat relativeXPos = 0.f;
    if (islessequal(self.contentSize.width, CGRectGetWidth(self.frame))) {
        relativeXPos = 0.f;
    }
    else {
        relativeXPos = self.contentOffset.x / (self.contentSize.width - CGRectGetWidth(self.frame));
    }
    
    CGFloat relativeYPos = 0.f;
    if (islessequal(self.contentSize.height, CGRectGetHeight(self.frame))) {
        relativeYPos = 0.f;
    }
    else {
        relativeYPos = self.contentOffset.y / (self.contentSize.height - CGRectGetHeight(self.frame));
    }
    
    // If reaching the top or the bottom of the master scroll view, prevent the other scroll views from
    // scrolling further (if enabled)
    BOOL bounces = [hls_getAssociatedObject(self, s_parallaxBouncesKey) boolValue];
    if (! bounces) {
        if (isless(relativeXPos, 0.f)) {
            relativeXPos = 0.f;
        }
        else if (isgreater(relativeXPos, 1.f)) {
            relativeXPos = 1.f;
        }
        
        if (isless(relativeYPos, 0.f)) {
            relativeYPos = 0.f;
        }
        else if (isgreater(relativeYPos, 1.f)) {
            relativeYPos = 1.f;
        }            
    }
    
    // Apply the same relative offset position to all scroll views to keep in sync
    for (UIScrollView *scrollView in synchronizedScrollViews) {
        CGFloat xPos = relativeXPos * (scrollView.contentSize.width - CGRectGetWidth(scrollView.frame));
        CGFloat yPos = relativeYPos * (scrollView.contentSize.height - CGRectGetHeight(scrollView.frame));
        scrollView.contentOffset = CGPointMake(xPos, yPos);
    }
}

#pragma mark Collecting scroll views which avoid the keyboard

+ (NSArray<UIScrollView *> *)keyboardAvoidingScrollViewsInView:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        
        // Do not go further when we have found a scroll view which avoids the keyboard. Any scroll view within
        // it with the same property does not need to be adjusted
        if (scrollView.avoidingKeyboard) {
            return @[scrollView];
        }
    }
    
    NSMutableArray<UIScrollView *> *keyboardAvoidingScrollViews = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        [keyboardAvoidingScrollViews addObjectsFromArray:[self keyboardAvoidingScrollViewsInView:subview]];
    }
    return [keyboardAvoidingScrollViews copy];
}

#pragma mark Notification callbacks

+ (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardEndFrameInWindow = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIView *activeView = [UIApplication sharedApplication].keyWindow.activeViewController.view;
    NSArray<UIScrollView *> *keyboardAvoidingScrollViews = [UIScrollView keyboardAvoidingScrollViewsInView:activeView];
    
    // Though we consider all scroll views avoiding the keyboard, some might not require any change depending on their position
    for (UIScrollView *scrollView in keyboardAvoidingScrollViews) {
        [self adjustOffsetForScrollView:scrollView withKeyboardEndFrameInWindow:keyboardEndFrameInWindow];
    }
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    for (UIScrollView *scrollView in [s_adjustedScrollViews copy]) {
        [self restoreOffsetForScrollView:scrollView];
    }
}

#pragma mark Managing offsets for individual scroll views

// Adjust offset and save settings (override existing settings if any)
+ (void)adjustOffsetForScrollView:(UIScrollView *)scrollView withKeyboardEndFrameInWindow:(CGRect)keyboardEndFrameInWindow
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_adjustedScrollViews = [NSMutableSet set];
        s_scrollViewOriginalBottomInsets = [NSMutableDictionary dictionary];
        s_scrollViewOriginalIndicatorBottomInsets = [NSMutableDictionary dictionary];
    });
    
    CGRect keyboardEndFrameInScrollView = [scrollView convertRect:keyboardEndFrameInWindow fromView:nil];
    
    // Calculate the required vertical adjustment
    CGFloat keyboardHeightAdjustment = CGRectGetHeight(scrollView.frame) - CGRectGetMinY(keyboardEndFrameInScrollView) + scrollView.contentOffset.y;
    
    // Check that the scroll view is neither completely covered by the keyboard, nor completely visible (in which case
    // no adjustment is required)
    if ((isless(keyboardHeightAdjustment, 0.f) || isgreater(keyboardHeightAdjustment, CGRectGetHeight(scrollView.frame)))) {
        return;
    }
    
    // The didShow notification is received consecutively without intermediate willHide notification. We need to preserve the
    // initial values in such cases
    NSValue *pointerKey = [NSValue valueWithNonretainedObject:scrollView];
    
    NSNumber *scrollViewOriginalBottomInset = s_scrollViewOriginalBottomInsets[pointerKey] ?: @(scrollView.contentInset.bottom);
    s_scrollViewOriginalBottomInsets[pointerKey] = scrollViewOriginalBottomInset;
    
    NSNumber *scrollViewOriginalIndicatorBottomInset = s_scrollViewOriginalIndicatorBottomInsets[pointerKey] ?: @(scrollView.scrollIndicatorInsets.bottom);
    s_scrollViewOriginalIndicatorBottomInsets[pointerKey] = scrollViewOriginalIndicatorBottomInset;
    
    // Keyboard distance is globally defined by the scroll view, but can be overridden for each view
    UIView *firstResponderView = scrollView.firstResponderView;
    CGFloat keyboardDistance = (firstResponderView.keyboardDistance == CGFLOAT_MAX) ? scrollView.keyboardDistance : firstResponderView.keyboardDistance;
    
    // Adjust content. Adjust depending on the space available vertically (398 is the horizontal keyboard height on a standard reference iPad)
    scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                               scrollView.contentInset.left,
                                               keyboardHeightAdjustment + keyboardDistance * (CGRectGetHeight([UIScreen mainScreen].applicationFrame) - CGRectGetHeight(keyboardEndFrameInWindow)) / (768.f - 398.f),
                                               scrollView.contentInset.right);
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.scrollIndicatorInsets.top,
                                                        scrollView.scrollIndicatorInsets.left,
                                                        keyboardHeightAdjustment,
                                                        scrollView.scrollIndicatorInsets.right);
    [s_adjustedScrollViews addObject:scrollView];
    
    // If the first responder is not visible, change the offset to make it visible. Do not do anything if the responder is the
    // scroll view itself (e.g. a UITextView)
    if (firstResponderView && firstResponderView != scrollView) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect firstResponderViewFrameInScrollView = [scrollView convertRect:firstResponderView.bounds fromView:firstResponderView];
            [scrollView scrollRectToVisible:firstResponderViewFrameInScrollView animated:NO];
        }];
    }
}

// Restore original offsets and remove saved settings
+ (void)restoreOffsetForScrollView:(UIScrollView *)scrollView
{
    if (! [s_adjustedScrollViews containsObject:scrollView]) {
        return;
    }
    
    NSValue *pointerKey = [NSValue valueWithNonretainedObject:scrollView];
    
    CGFloat scrollViewOriginalBottomInset = (s_scrollViewOriginalBottomInsets[pointerKey]).floatValue;
    scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                               scrollView.contentInset.left,
                                               scrollViewOriginalBottomInset,
                                               scrollView.contentInset.right);
    
    CGFloat scrollViewOriginalIndicatorBottomInset = (s_scrollViewOriginalBottomInsets[pointerKey]).floatValue;
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.scrollIndicatorInsets.top,
                                                        scrollView.scrollIndicatorInsets.left,
                                                        scrollViewOriginalIndicatorBottomInset,
                                                        scrollView.scrollIndicatorInsets.right);
    
    [s_adjustedScrollViews removeObject:scrollView];
    [s_scrollViewOriginalBottomInsets removeObjectForKey:pointerKey];
    [s_scrollViewOriginalIndicatorBottomInsets removeObjectForKey:pointerKey];
}

@end

#pragma mark Global notification registration

__attribute__ ((constructor)) static void HLSTextFieldInit(void)
{
    [[NSNotificationCenter defaultCenter] addObserver:[UIScrollView class]
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[UIScrollView class]
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark Swizzled method implementations

static void swizzle_setContentOffset(UIScrollView *self, SEL _cmd, CGPoint contentOffset)
{
    s_setContentOffset(self, _cmd, contentOffset);
    [self synchronizeScrolling];
}

static void swizzle_willMoveToWindow(UIScrollView *self, SEL _cmd, UIWindow *window)
{
    s_willMoveToWindow(self, _cmd, window);
    
    // Ensure correct offset even if the scroll view is added after the keyboard has been displayed
    if (window) {
        HLSKeyboardInformation *keyboardInformation = [HLSKeyboardInformation keyboardInformation];
        if (keyboardInformation) {
            [UIScrollView adjustOffsetForScrollView:self withKeyboardEndFrameInWindow:keyboardInformation.endFrame];
        }
    }
}

static void swizzle_layoutSubviews(UIScrollView *self, SEL _cmd)
{
    s_layoutSubviews(self, _cmd);
    
    // Update offset when the view layout changes
    HLSKeyboardInformation *keyboardInformation = [HLSKeyboardInformation keyboardInformation];
    if (keyboardInformation) {
        [UIScrollView adjustOffsetForScrollView:self withKeyboardEndFrameInWindow:keyboardInformation.endFrame];
    }
}
