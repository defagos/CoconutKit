//
//  UIScrollView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIScrollView+HLSExtensions.h"

#import "HLSAssert.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import <objc/runtime.h>

/**
 * There are at least three way to detect contentOffset changes of the master view:
 *   - use an internal delegate which transparently forwards events to the real scroll view delegate, and which
 *     performs synchronization in its scrollViewDidScroll: method implementation. This might break if 
 *     UIScrollViewDelegate changes, though
 *   - use KVO on contentOffset. The problem is that the observeValue... method to implement could be overridden by
 *     existing subclasses of UIScrollView, or even by categories. This is clearly not robust enough
 *   - swizzling contentOffset mutators. This is the safest approach which has been retained here
 */

// Associated object keys
static void *s_synchronizedScrollViewsKey = &s_synchronizedScrollViewsKey;
static void *s_parallaxBouncesKey = &s_parallaxBouncesKey;

// Original implementation of the methods we swizzle
static void (*s_UIScrollView__setContentOffset_Imp)(id, SEL, CGPoint) = NULL;

// Swizzled method implementations
static void swizzled_UIScrollView__setContentOffset_Imp(UIScrollView *self, SEL _cmd, CGPoint contentOffset);

@interface UIScrollView (HLSExtensionsPrivate)

- (void)synchronizeScrolling;

@end

@implementation UIScrollView (HLSExtensions)

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
    
    objc_setAssociatedObject(self, s_synchronizedScrollViewsKey, scrollViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, s_parallaxBouncesKey, [NSNumber numberWithBool:bounces], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeSynchronization
{
    objc_setAssociatedObject(self, s_synchronizedScrollViewsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, s_parallaxBouncesKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIScrollView (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UIScrollView__setContentOffset_Imp = (void (*)(id, SEL, CGPoint))HLSSwizzleSelector(self, 
                                                                                          @selector(setContentOffset:), 
                                                                                          (IMP)swizzled_UIScrollView__setContentOffset_Imp);
}

#pragma mark Scrolling synchronization

- (void)synchronizeScrolling
{
    NSArray *synchronizedScrollViews = objc_getAssociatedObject(self, s_synchronizedScrollViewsKey);
    if (! synchronizedScrollViews) {
        return;
    }
    
    // Calculate the relative offset position (in [0; 1]) of the receiver
    CGFloat relativeXPos = 0.f;
    if (floatle(self.contentSize.width, CGRectGetWidth(self.frame))) {
        relativeXPos = 0.f;
    }
    else {
        relativeXPos = self.contentOffset.x / (self.contentSize.width - CGRectGetWidth(self.frame));
    }
    
    CGFloat relativeYPos = 0.f;
    if (floatle(self.contentSize.height, CGRectGetHeight(self.frame))) {
        relativeYPos = 0.f;
    }
    else {
        relativeYPos = self.contentOffset.y / (self.contentSize.height - CGRectGetHeight(self.frame));
    }
    
    // If reaching the top or the bottom of the master scroll view, prevent the other scroll views from
    // scrolling further (if enabled)
    BOOL bounces = [objc_getAssociatedObject(self, s_parallaxBouncesKey) boolValue];
    if (! bounces) {
        if (floatlt(relativeXPos, 0.f)) {
            relativeXPos = 0.f;
        }
        else if (floatgt(relativeXPos, 1.f)) {
            relativeXPos = 1.f;
        }
        
        if (floatlt(relativeYPos, 0.f)) {
            relativeYPos = 0.f;
        }
        else if (floatgt(relativeYPos, 1.f)) {
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

@end

#pragma mark Swizzled method implementations

static void swizzled_UIScrollView__setContentOffset_Imp(UIScrollView *self, SEL _cmd, CGPoint contentOffset)
{
    (*s_UIScrollView__setContentOffset_Imp)(self, _cmd, contentOffset);
    [self synchronizeScrolling];
}
