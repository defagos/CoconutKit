//
//  UIActionSheet+HLSExtensions.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 24.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIActionSheet+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"

// Keys for associated objects
static void *s_parentViewKey = &s_parentViewKey;

// Original implementations of the methods we swizzle
static void (*s_UIActionSheet__showFromToolbar_Imp)(id, SEL, id) = NULL;
static void (*s_UIActionSheet__showFromTabBar_Imp)(id, SEL, id) = NULL;
static void (*s_UIActionSheet__showFromBarButtonItem_animated_Imp)(id, SEL, id, BOOL) = NULL;
static void (*s_UIActionSheet__showFromRect_inView_animated_Imp)(id, SEL, CGRect, id, BOOL) = NULL;
static void (*s_UIActionSheet__showInView_Imp)(id, SEL, id) = NULL;
static void (*s_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp)(id, SEL, NSInteger, BOOL) = NULL;

HLSLinkCategory(UIActionSheet_HLSExtensions)

@interface UIActionSheet (HLSExtensionsPrivate)

- (void)swizzledShowFromToolbar:(UIToolbar *)toolbar;
- (void)swizzledShowFromTabBar:(UITabBar *)tabBar;
- (void)swizzledShowFromBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated;
- (void)swizzledShowFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;
- (void)swizzledShowInView:(UIView *)view;
- (void)swizzledDismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end

@implementation UIActionSheet (HLSExtensions)

- (UIView *)parentView
{
    return objc_getAssociatedObject(self, s_parentViewKey);
}

@end

@implementation UIActionSheet (HLSExtensionsPrivate)

+ (void)load
{
    s_UIActionSheet__showFromToolbar_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(showFromToolbar:), @selector(swizzledShowFromToolbar:));
    s_UIActionSheet__showFromTabBar_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(showFromTabBar:), @selector(swizzledShowFromTabBar:));
    s_UIActionSheet__showFromBarButtonItem_animated_Imp = (void (*)(id, SEL, id, BOOL))HLSSwizzleSelector(self, 
                                                                                                          @selector(showFromBarButtonItem:animated:), 
                                                                                                          @selector(swizzledShowFromBarButtonItem:animated:));
    s_UIActionSheet__showFromRect_inView_animated_Imp = (void (*)(id, SEL, CGRect, id, BOOL))HLSSwizzleSelector(self,
                                                                                                                @selector(showFromRect:inView:animated:), 
                                                                                                                @selector(swizzledShowFromRect:inView:animated:));
    s_UIActionSheet__showInView_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(showInView:), @selector(swizzledShowInView:));
    s_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp = (void (*)(id, SEL, NSInteger, BOOL))HLSSwizzleSelector(self,
                                                                                                                         @selector(dismissWithClickedButtonIndex:animated:), 
                                                                                                                         @selector(swizzledDismissWithClickedButtonIndex:animated:));
}

- (void)swizzledShowFromToolbar:(UIToolbar *)toolbar
{
    objc_setAssociatedObject(self, s_parentViewKey, toolbar, OBJC_ASSOCIATION_ASSIGN);
    (*s_UIActionSheet__showFromToolbar_Imp)(self, @selector(showFromToolbar:), toolbar);
}

- (void)swizzledShowFromTabBar:(UITabBar *)tabBar
{
    objc_setAssociatedObject(self, s_parentViewKey, tabBar, OBJC_ASSOCIATION_ASSIGN);
    (*s_UIActionSheet__showFromTabBar_Imp)(self, @selector(showFromTabBar:), tabBar);
}

- (void)swizzledShowFromBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated
{
    objc_setAssociatedObject(self, s_parentViewKey, barButtonItem, OBJC_ASSOCIATION_ASSIGN);
    (*s_UIActionSheet__showFromBarButtonItem_animated_Imp)(self, @selector(showFromBarButtonItem:animated:), barButtonItem, animated);
}

- (void)swizzledShowFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    objc_setAssociatedObject(self, s_parentViewKey, view, OBJC_ASSOCIATION_ASSIGN);
    (*s_UIActionSheet__showFromRect_inView_animated_Imp)(self, @selector(showFromRect:inView:animated:), rect, view, animated);
}

- (void)swizzledShowInView:(UIView *)view
{
    objc_setAssociatedObject(self, s_parentViewKey, view, OBJC_ASSOCIATION_ASSIGN);
    (*s_UIActionSheet__showInView_Imp)(self, @selector(showInView:), view);
}

// The dismissWithClickedButtonIndex:animated: method is also called when the user dismisses
// the action sheet by tapping outside it
- (void)swizzledDismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    (*s_UIActionSheet__dismissWithClickedButtonIndex_animated_Imp)(self, @selector(dismissWithClickedButtonIndex:animated:), buttonIndex, animated);
    objc_setAssociatedObject(self, s_parentViewKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end
