//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIActionSheet+HLSExtensions.h"

#import "HLSRuntime.h"

// Keys for associated objects
static void *s_ownerKey = &s_ownerKey;

// Original implementation of the methods we swizzle
static void (*s_showFromToolbar)(id, SEL, id) = NULL;
static void (*s_showFromTabBar)(id, SEL, id) = NULL;
static void (*s_showFromBarButtonItem_animated)(id, SEL, id, BOOL) = NULL;
static void (*s_showFromRect_inView_animated)(id, SEL, CGRect, id, BOOL) = NULL;
static void (*s_showInView)(id, SEL, id) = NULL;
static void (*s_dismissWithClickedButtonIndex_animated)(id, SEL, NSInteger, BOOL) = NULL;

// Swizzled method implementations
static void swizzle_showFromToolbar(UIActionSheet *self, SEL _cmd, UIToolbar *toolbar);
static void swizzle_showFromTabBar(UIActionSheet *self, SEL _cmd, UITabBar *tabBar);
static void swizzle_showFromBarButtonItem_animated(UIActionSheet *self, SEL _cmd, UIBarButtonItem *barButtonItem, BOOL animated);
static void swizzle_showFromRect_inView_animated(UIActionSheet *self, SEL _cmd, CGRect rect, UIView *view, BOOL animated);
static void swizzle_showInView(UIActionSheet *self, SEL _cmd, UIView *view);
static void swizzle_dismissWithClickedButtonIndex_animated(UIActionSheet *self, SEL _cmd, NSInteger buttonIndex, BOOL animated);

@implementation UIActionSheet (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(showFromToolbar:), swizzle_showFromToolbar, &s_showFromToolbar);
    HLSSwizzleSelector(self, @selector(showFromTabBar:), swizzle_showFromTabBar, &s_showFromTabBar);
    HLSSwizzleSelector(self, @selector(showFromBarButtonItem:animated:), swizzle_showFromBarButtonItem_animated, &s_showFromBarButtonItem_animated);
    HLSSwizzleSelector(self, @selector(showFromRect:inView:animated:), swizzle_showFromRect_inView_animated, &s_showFromRect_inView_animated);
    HLSSwizzleSelector(self, @selector(showInView:), swizzle_showInView, &s_showInView);
    HLSSwizzleSelector(self, @selector(dismissWithClickedButtonIndex:animated:), swizzle_dismissWithClickedButtonIndex_animated, &s_dismissWithClickedButtonIndex_animated);
}

#pragma mark Accessors and mutators

- (id)owner
{
    return hls_getAssociatedObject(self, s_ownerKey);
}

@end

#pragma mark Swizzled method implementations

static void swizzle_showFromToolbar(UIActionSheet *self, SEL _cmd, UIToolbar *toolbar)
{
    hls_setAssociatedObject(self, s_ownerKey, toolbar, HLS_ASSOCIATION_WEAK_NONATOMIC);
    s_showFromToolbar(self, _cmd, toolbar);
}

static void swizzle_showFromTabBar(UIActionSheet *self, SEL _cmd, UITabBar *tabBar)
{
    hls_setAssociatedObject(self, s_ownerKey, tabBar, HLS_ASSOCIATION_WEAK_NONATOMIC);
    s_showFromTabBar(self, _cmd, tabBar);
}

static void swizzle_showFromBarButtonItem_animated(UIActionSheet *self, SEL _cmd, UIBarButtonItem *barButtonItem, BOOL animated)
{
    hls_setAssociatedObject(self, s_ownerKey, barButtonItem, HLS_ASSOCIATION_WEAK_NONATOMIC);
    s_showFromBarButtonItem_animated(self, _cmd, barButtonItem, animated);
}

static void swizzle_showFromRect_inView_animated(UIActionSheet *self, SEL _cmd, CGRect rect, UIView *view, BOOL animated)
{
    hls_setAssociatedObject(self, s_ownerKey, view, HLS_ASSOCIATION_WEAK_NONATOMIC);
    s_showFromRect_inView_animated(self, _cmd, rect, view, animated);
}

static void swizzle_showInView(UIActionSheet *self, SEL _cmd, UIView *view)
{
    hls_setAssociatedObject(self, s_ownerKey, view, HLS_ASSOCIATION_WEAK_NONATOMIC);
    s_showInView(self, _cmd, view);
}

// The dismissWithClickedButtonIndex:animated: method is also called when the user dismisses
// the action sheet by tapping outside it
static void swizzle_dismissWithClickedButtonIndex_animated(UIActionSheet *self, SEL _cmd, NSInteger buttonIndex, BOOL animated)
{
    s_dismissWithClickedButtonIndex_animated(self, _cmd, buttonIndex, animated);
    hls_setAssociatedObject(self, s_ownerKey, nil, HLS_ASSOCIATION_WEAK_NONATOMIC);
}
