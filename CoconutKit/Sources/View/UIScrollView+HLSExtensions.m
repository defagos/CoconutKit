//
//  UIScrollView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UIScrollView+HLSExtensions.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UIView+HLSExtensions.h"
#import "UIWindow+HLSExtensions.h"

#import <objc/runtime.h>

// Associated object keys
static void *s_synchronizedScrollViewsKey = &s_synchronizedScrollViewsKey;
static void *s_parallaxBouncesKey = &s_parallaxBouncesKey;
static void *s_avoidingKeyboardKey = &s_avoidingKeyboardKey;
static void *s_keyboardDistanceKey = &s_keyboardDistanceKey;

// Original implementation of the methods we swizzle
static void (*s_UIScrollView__setContentOffset_Imp)(id, SEL, CGPoint) = NULL;

// Swizzled method implementations
static void swizzled_UIScrollView__setContentOffset_Imp(UIScrollView *self, SEL _cmd, CGPoint contentOffset);

static NSArray *s_adjustedScrollViews = nil;
static NSDictionary *s_scrollViewOriginalBottomInsets = nil;
static NSDictionary *s_scrollViewOriginalIndicatorBottomInsets = nil;

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
    hls_setAssociatedObject(self, s_avoidingKeyboardKey, @(avoidingKeyboard), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)keyboardDistance
{
    static const CGFloat HLSDefaultKeyboardDistance = 10.f;
    
    NSNumber *keyboardDistanceNumber = hls_getAssociatedObject(self, s_keyboardDistanceKey);
    return keyboardDistanceNumber ? [keyboardDistanceNumber floatValue] : HLSDefaultKeyboardDistance;
}

- (void)setKeyboardDistance:(CGFloat)keyboardDistance
{
    hls_setAssociatedObject(self, s_keyboardDistanceKey, @(keyboardDistance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Synchronizing scroll views

- (void)synchronizeWithScrollViews:(NSArray *)scrollViews bounces:(BOOL)bounces
{
    HLSAssertObjectsInEnumerationAreKindOfClass(scrollViews, UIScrollView);
    
    if (! scrollViews || [scrollViews count] == 0) {
        HLSLoggerError(@"No scroll views to synchronize");
        return;
    }
    
    if ([scrollViews containsObject:self]) {
        HLSLoggerError(@"A scroll view cannot be synchronized with itself");
        return;
    }
    
    hls_setAssociatedObject(self, s_synchronizedScrollViewsKey, scrollViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    hls_setAssociatedObject(self, s_parallaxBouncesKey, @(bounces), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeSynchronization
{
    hls_setAssociatedObject(self, s_synchronizedScrollViewsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    hls_setAssociatedObject(self, s_parallaxBouncesKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIScrollView (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UIScrollView__setContentOffset_Imp = (void (*)(id, SEL, CGPoint))hls_class_swizzleSelector(self,
                                                                                                 @selector(setContentOffset:),
                                                                                                 (IMP)swizzled_UIScrollView__setContentOffset_Imp);
}

#pragma mark Scrolling synchronization

- (void)synchronizeScrolling
{
    NSArray *synchronizedScrollViews = hls_getAssociatedObject(self, s_synchronizedScrollViewsKey);
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

+ (NSArray *)keyboardAvoidingScrollViewsInView:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        
        // Do not go further when we have found a scroll view which avoids the keyboard. Any scroll view within
        // it with the same property does not need to be adjusted
        if (scrollView.avoidingKeyboard) {
            return @[scrollView];
        }
    }
    
    NSMutableArray *keyboardAvoidingScrollViews = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        [keyboardAvoidingScrollViews addObjectsFromArray:[self keyboardAvoidingScrollViewsInView:subview]];
    }
    return [NSArray arrayWithArray:keyboardAvoidingScrollViews];
}

#pragma mark Notification callbacks

+ (void)keyboardWillShow:(NSNotification *)notification
{
    UIView *activeView = [UIApplication sharedApplication].keyWindow.activeViewController.view;
    NSArray *keyboardAvoidingScrollViews = [UIScrollView keyboardAvoidingScrollViewsInView:activeView];
    
    CGRect keyboardEndFrameInWindow = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSMutableArray *adjustedScrollViews = [NSMutableArray array];
    
    NSMutableDictionary *scrollViewOriginalBottomInsets = [NSMutableDictionary dictionary];
    NSMutableDictionary *scrollViewOriginalIndicatorBottomInsets = [NSMutableDictionary dictionary];
    
    // Though we consider all scroll views avoiding the keyboard, some might not require any change depending on their position
    for (UIScrollView *scrollView in keyboardAvoidingScrollViews) {
        CGRect keyboardEndFrameInScrollView = [scrollView convertRect:keyboardEndFrameInWindow fromView:nil];
        
        // Calculate the required vertical adjustment
        CGFloat keyboardHeightAdjustment = CGRectGetHeight(scrollView.frame) - CGRectGetMinY(keyboardEndFrameInScrollView) + scrollView.contentOffset.y;
        
        // Check that the scroll view is neither completely covered by the keyboard, nor completely visible (in which case
        // no adjustment is required)
        if ((isless(keyboardHeightAdjustment, 0.f) || isgreater(keyboardHeightAdjustment, CGRectGetHeight(scrollView.frame)))) {
            continue;
        }
        
        // The didShow notification is received consecutively without intermediate willHide notification. We need to preserve the
        // initial values in such cases
        NSValue *pointerKey = [NSValue valueWithNonretainedObject:scrollView];
        
        NSNumber *scrollViewOriginalBottomInset = [s_scrollViewOriginalBottomInsets objectForKey:pointerKey] ?: @(scrollView.contentInset.bottom);
        [scrollViewOriginalBottomInsets setObject:scrollViewOriginalBottomInset forKey:pointerKey];
        
        NSNumber *scrollViewOriginalIndicatorBottomInset = [s_scrollViewOriginalIndicatorBottomInsets objectForKey:pointerKey] ?: @(scrollView.scrollIndicatorInsets.bottom);
        [scrollViewOriginalIndicatorBottomInsets setObject:scrollViewOriginalIndicatorBottomInset forKey:pointerKey];
        
        // Adjust content
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                                   scrollView.contentInset.left,
                                                   keyboardHeightAdjustment + scrollView.keyboardDistance,
                                                   scrollView.contentInset.right);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.scrollIndicatorInsets.top,
                                                            scrollView.scrollIndicatorInsets.left,
                                                            keyboardHeightAdjustment,
                                                            scrollView.scrollIndicatorInsets.right);
        [adjustedScrollViews addObject:scrollView];
        
        // Find if the first responder is contained within the scroll view. Only for scroll views which might embed other controls
        if ([scrollView isMemberOfClass:[UIScrollView class]]) {
            UIView *firstResponderView = [scrollView firstResponderView];
            if (firstResponderView) {
                // If the first responder is not visible, change the offset to make it visible
                [UIView animateWithDuration:0.25 animations:^{
                    CGRect firstResponderViewFrameInScrollView = [scrollView convertRect:firstResponderView.bounds fromView:firstResponderView];
                    [scrollView scrollRectToVisible:firstResponderViewFrameInScrollView animated:NO];
                }];
            }
        }
    }
    
    s_adjustedScrollViews = [NSArray arrayWithArray:adjustedScrollViews];
    s_scrollViewOriginalBottomInsets = [NSDictionary dictionaryWithDictionary:scrollViewOriginalBottomInsets];
    s_scrollViewOriginalIndicatorBottomInsets = [NSDictionary dictionaryWithDictionary:scrollViewOriginalIndicatorBottomInsets];
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    for (UIScrollView *scrollView in s_adjustedScrollViews) {
        NSValue *pointerKey = [NSValue valueWithNonretainedObject:scrollView];
        
        CGFloat scrollViewOriginalBottomInset = [[s_scrollViewOriginalBottomInsets objectForKey:pointerKey] floatValue];
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                                   scrollView.contentInset.left,
                                                   scrollViewOriginalBottomInset,
                                                   scrollView.contentInset.right);
        
        CGFloat scrollViewOriginalIndicatorBottomInset = [[s_scrollViewOriginalBottomInsets objectForKey:pointerKey] floatValue];
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.scrollIndicatorInsets.top,
                                                            scrollView.scrollIndicatorInsets.left,
                                                            scrollViewOriginalIndicatorBottomInset,
                                                            scrollView.scrollIndicatorInsets.right);
    }
    
    s_adjustedScrollViews = nil;
    s_scrollViewOriginalBottomInsets = nil;
    s_scrollViewOriginalIndicatorBottomInsets = nil;
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

static void swizzled_UIScrollView__setContentOffset_Imp(UIScrollView *self, SEL _cmd, CGPoint contentOffset)
{
    (*s_UIScrollView__setContentOffset_Imp)(self, _cmd, contentOffset);
    [self synchronizeScrolling];
}
