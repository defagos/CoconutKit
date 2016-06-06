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

// Swizzled method implementations
static void swizzle_setContentOffset(UIScrollView *self, SEL _cmd, CGPoint contentOffset);
static void swizzle_willMoveToWindow(UIScrollView *self, SEL _cmd, UIWindow *window);

static NSMutableSet<UIScrollView *> *s_adjustedScrollViews = nil;
static NSMutableDictionary<NSValue *, NSNumber *> *s_scrollViewOriginalBottomInsets = nil;
static NSMutableDictionary<NSValue *, NSNumber *> *s_scrollViewOriginalIndicatorBottomInsets = nil;

@interface UIScrollView (HLSExtensionsPrivate)

- (void)synchronizeScrolling;

@end

@implementation UIScrollView (HLSExtensions)

#pragma mark Class methods

+ (nullable NSArray<__kindof UIScrollView *> *)adjustedScrollViews
{
    return s_adjustedScrollViews.count != 0 ? [s_adjustedScrollViews copy] : nil;
}

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
        [scrollView adjustOffsetWithKeyboardEndFrameInWindow:keyboardEndFrameInWindow];
    }
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    for (UIScrollView *scrollView in [s_adjustedScrollViews copy]) {
        [scrollView restoreOffset];
    }
}

#pragma mark Managing offsets for individual scroll views

// Adjust offset and save settings (override existing settings if any)
- (void)adjustOffsetWithKeyboardEndFrameInWindow:(CGRect)keyboardEndFrameInWindow
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_adjustedScrollViews = [NSMutableSet set];
        s_scrollViewOriginalBottomInsets = [NSMutableDictionary dictionary];
        s_scrollViewOriginalIndicatorBottomInsets = [NSMutableDictionary dictionary];
    });
    
    CGRect keyboardEndFrameInScrollView = [self convertRect:keyboardEndFrameInWindow fromView:nil];
    
    // Calculate the required vertical adjustment
    CGFloat keyboardHeightAdjustment = CGRectGetHeight(self.frame) - CGRectGetMinY(keyboardEndFrameInScrollView) + self.contentOffset.y;
    
    // Check that the scroll view is neither completely covered by the keyboard, nor completely visible (in which case
    // no adjustment is required)
    if ((isless(keyboardHeightAdjustment, 0.f) || isgreater(keyboardHeightAdjustment, CGRectGetHeight(self.frame)))) {
        return;
    }
    
    // The didShow notification is received consecutively without intermediate willHide notification. We need to preserve the
    // initial values in such cases
    NSValue *pointerKey = [NSValue valueWithNonretainedObject:self];
    
    NSNumber *scrollViewOriginalBottomInset = s_scrollViewOriginalBottomInsets[pointerKey] ?: @(self.contentInset.bottom);
    s_scrollViewOriginalBottomInsets[pointerKey] = scrollViewOriginalBottomInset;
    
    NSNumber *scrollViewOriginalIndicatorBottomInset = s_scrollViewOriginalIndicatorBottomInsets[pointerKey] ?: @(self.scrollIndicatorInsets.bottom);
    s_scrollViewOriginalIndicatorBottomInsets[pointerKey] = scrollViewOriginalIndicatorBottomInset;
    
    // Keyboard distance is globally defined by the scroll view, but can be overridden for each view
    UIView *firstResponderView = self.firstResponderView;
    CGFloat keyboardDistance = (firstResponderView.keyboardDistance == CGFLOAT_MAX) ? self.keyboardDistance : firstResponderView.keyboardDistance;
    
    // Adjust content. Adjust depending on the space available vertically (398 is the horizontal keyboard height on a standard reference iPad)
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top,
                                         self.contentInset.left,
                                         keyboardHeightAdjustment + keyboardDistance * (CGRectGetHeight([UIScreen mainScreen].applicationFrame) - CGRectGetHeight(keyboardEndFrameInWindow)) / (768.f - 398.f),
                                         self.contentInset.right);
    self.scrollIndicatorInsets = UIEdgeInsetsMake(self.scrollIndicatorInsets.top,
                                                  self.scrollIndicatorInsets.left,
                                                  keyboardHeightAdjustment,
                                                  self.scrollIndicatorInsets.right);
    [s_adjustedScrollViews addObject:self];
    
    // If the first responder is not visible, change the offset to make it visible. Do not do anything if the responder is the
    // scroll view itself (e.g. a UITextView)
    if (firstResponderView && firstResponderView != self) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect firstResponderViewFrameInScrollView = [self convertRect:firstResponderView.bounds fromView:firstResponderView];
            [self scrollRectToVisible:firstResponderViewFrameInScrollView animated:NO];
        }];
    }
}

// Restore original offsets and remove saved settings
- (void)restoreOffset
{
    if (! [s_adjustedScrollViews containsObject:self]) {
        return;
    }
    
    NSValue *pointerKey = [NSValue valueWithNonretainedObject:self];
    
    CGFloat scrollViewOriginalBottomInset = (s_scrollViewOriginalBottomInsets[pointerKey]).floatValue;
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top,
                                         self.contentInset.left,
                                         scrollViewOriginalBottomInset,
                                         self.contentInset.right);
    
    CGFloat scrollViewOriginalIndicatorBottomInset = (s_scrollViewOriginalBottomInsets[pointerKey]).floatValue;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(self.scrollIndicatorInsets.top,
                                                  self.scrollIndicatorInsets.left,
                                                  scrollViewOriginalIndicatorBottomInset,
                                                  self.scrollIndicatorInsets.right);
    
    [s_adjustedScrollViews removeObject:self];
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
            [self adjustOffsetWithKeyboardEndFrameInWindow:keyboardInformation.endFrame];
        }
    }
}
