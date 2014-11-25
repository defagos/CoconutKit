//
//  UIActionSheet+HLSExtensions.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 24.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UIActionSheet+HLSExtensions.h"

#import "HLSRuntime.h"

// Keys for associated objects
static void *s_ownerKey = &s_ownerKey;

// Original implementation of the methods we swizzle
static void (*s_UIActionSheet__showFromToolbar_Imp)(id, SEL, id) = NULL;
static void (*s_UIActionSheet__showFromTabBar_Imp)(id, SEL, id) = NULL;
static void (*s_UIActionSheet__showFromBarButtonItem_animated_Imp)(id, SEL, id, BOOL) = NULL;
static void (*s_UIActionSheet__showFromRect_inView_animated_Imp)(id, SEL, CGRect, id, BOOL) = NULL;
static void (*s_UIActionSheet__showInView_Imp)(id, SEL, id) = NULL;
static void (*s_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp)(id, SEL, NSInteger, BOOL) = NULL;

// Swizzled method implementations
static void swizzled_UIActionSheet__showFromToolbar_Imp(UIActionSheet *self, SEL _cmd, UIToolbar *toolbar);
static void swizzled_UIActionSheet__showFromTabBar_Imp(UIActionSheet *self, SEL _cmd, UITabBar *tabBar);
static void swizzled_UIActionSheet__showFromBarButtonItem_animated_Imp(UIActionSheet *self, SEL _cmd, UIBarButtonItem *barButtonItem, BOOL animated);
static void swizzled_UIActionSheet__showFromRect_inView_animated_Imp(UIActionSheet *self, SEL _cmd, CGRect rect, UIView *view, BOOL animated);
static void swizzled_UIActionSheet__showInView_Imp(UIActionSheet *self, SEL _cmd, UIView *view);
static void swizzled_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp(UIActionSheet *self, SEL _cmd, NSInteger buttonIndex, BOOL animated);

@implementation UIActionSheet (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    s_UIActionSheet__showFromToolbar_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                            @selector(showFromToolbar:),
                                                                                            (IMP)swizzled_UIActionSheet__showFromToolbar_Imp);
    s_UIActionSheet__showFromTabBar_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                           @selector(showFromTabBar:),
                                                                                           (IMP)swizzled_UIActionSheet__showFromTabBar_Imp);
    s_UIActionSheet__showFromBarButtonItem_animated_Imp = (void (*)(id, SEL, id, BOOL))hls_class_swizzleSelector(self,
                                                                                                                 @selector(showFromBarButtonItem:animated:),
                                                                                                                 (IMP)swizzled_UIActionSheet__showFromBarButtonItem_animated_Imp);
    s_UIActionSheet__showFromRect_inView_animated_Imp = (void (*)(id, SEL, CGRect, id, BOOL))hls_class_swizzleSelector(self,
                                                                                                                       @selector(showFromRect:inView:animated:),
                                                                                                                       (IMP)swizzled_UIActionSheet__showFromRect_inView_animated_Imp);
    s_UIActionSheet__showInView_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                       @selector(showInView:),
                                                                                       (IMP)swizzled_UIActionSheet__showInView_Imp);
    s_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp = (void (*)(id, SEL, NSInteger, BOOL))hls_class_swizzleSelector(self,
                                                                                                                                @selector(dismissWithClickedButtonIndex:animated:),
                                                                                                                                (IMP)swizzled_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp);
}

#pragma mark Accessors and mutators

- (id)owner
{
    return hls_getAssociatedObject(self, s_ownerKey);
}

@end

#pragma mark Swizzled method implementations

static void swizzled_UIActionSheet__showFromToolbar_Imp(UIActionSheet *self, SEL _cmd, UIToolbar *toolbar)
{
    hls_setAssociatedObject(self, s_ownerKey, toolbar, HLS_ASSOCIATION_WEAK_NONATOMIC);
    (*s_UIActionSheet__showFromToolbar_Imp)(self, _cmd, toolbar);
}

static void swizzled_UIActionSheet__showFromTabBar_Imp(UIActionSheet *self, SEL _cmd, UITabBar *tabBar)
{
    hls_setAssociatedObject(self, s_ownerKey, tabBar, HLS_ASSOCIATION_WEAK_NONATOMIC);
    (*s_UIActionSheet__showFromTabBar_Imp)(self, _cmd, tabBar);
}

static void swizzled_UIActionSheet__showFromBarButtonItem_animated_Imp(UIActionSheet *self, SEL _cmd, UIBarButtonItem *barButtonItem, BOOL animated)
{
    hls_setAssociatedObject(self, s_ownerKey, barButtonItem, HLS_ASSOCIATION_WEAK_NONATOMIC);
    (*s_UIActionSheet__showFromBarButtonItem_animated_Imp)(self, _cmd, barButtonItem, animated);
}

static void swizzled_UIActionSheet__showFromRect_inView_animated_Imp(UIActionSheet *self, SEL _cmd, CGRect rect, UIView *view, BOOL animated)
{
    hls_setAssociatedObject(self, s_ownerKey, view, HLS_ASSOCIATION_WEAK_NONATOMIC);
    (*s_UIActionSheet__showFromRect_inView_animated_Imp)(self, _cmd, rect, view, animated);
}

static void swizzled_UIActionSheet__showInView_Imp(UIActionSheet *self, SEL _cmd, UIView *view)
{
    hls_setAssociatedObject(self, s_ownerKey, view, HLS_ASSOCIATION_WEAK_NONATOMIC);
    (*s_UIActionSheet__showInView_Imp)(self, _cmd, view);
}

// The dismissWithClickedButtonIndex:animated: method is also called when the user dismisses
// the action sheet by tapping outside it
static void swizzled_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp(UIActionSheet *self, SEL _cmd, NSInteger buttonIndex, BOOL animated)
{
    (*s_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp)(self, _cmd, buttonIndex, animated);
    hls_setAssociatedObject(self, s_ownerKey, nil, HLS_ASSOCIATION_WEAK_NONATOMIC);
}
