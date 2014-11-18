//
//  UIPopoverController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/17/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UIPopoverController+HLSExtensions.h"

#import "HLSRuntime.h"
#import "UIViewController+HLSExtensions.h"

// TODO: Remove when CoconutKit requires iOS >= 8 (which introdueced -popoverPresentationController)

// Associated object keys
static void *s_popoverControllerKey = &s_popoverControllerKey;

// Original implementation of the methods we swizzle
static id (*s_UIPopoverController__initWithContentViewController_Imp)(id, SEL, id) = NULL;
static void (*s_UIPopoverController__dealloc_Imp)(__unsafe_unretained id, SEL) = NULL;
static void (*s_UIPopoverController__setContentViewController_animated_Imp)(id, SEL, id, BOOL) = NULL;

// Swizzled method implementations
static id swizzled_UIPopoverController__initWithContentViewController_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController);
static void swizzled_UIPopoverController__dealloc_Imp(__unsafe_unretained UIPopoverController *self, SEL _cmd);
static void swizzled_UIPopoverController__setContentViewController_animated_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController, BOOL animated);

@interface UIPopoverController (HLSExtensionsPrivate)

// Currently empty. Just used for method swizzling

@end

@implementation UIPopoverController (HLSExtensionsPrivate)

+ (void)load
{
    // initWithContentViewController: sadly does not rely on setContentViewController:animated: to set its content view controller. Must
    // swizzle it as well
    s_UIPopoverController__initWithContentViewController_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                                              @selector(initWithContentViewController:),
                                                                                                              (IMP)swizzled_UIPopoverController__initWithContentViewController_Imp);
    s_UIPopoverController__dealloc_Imp = (void (*)(__unsafe_unretained id, SEL))hls_class_swizzleSelector(self,
                                                                                                          NSSelectorFromString(@"dealloc"),
                                                                                                          (IMP)swizzled_UIPopoverController__dealloc_Imp);
    s_UIPopoverController__setContentViewController_animated_Imp = (void (*)(id, SEL, id, BOOL))hls_class_swizzleSelector(self,
                                                                                                                          @selector(setContentViewController:animated:),
                                                                                                                          (IMP)swizzled_UIPopoverController__setContentViewController_animated_Imp);
}

@end

@implementation UIViewController (UIPopoverController_HLSExtensions)

- (UIPopoverController *)popoverController
{
    UIPopoverController *popoverController = objc_getAssociatedObject(self, s_popoverControllerKey);
    if (popoverController) {
        return popoverController;
    }
    else {
        return self.parentViewController.popoverController;
    }
}

@end

static id swizzled_UIPopoverController__initWithContentViewController_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController)
{
    // The -viewDidLoad method is triggered from the -initWithContentViewController method. If we want the parent information to be available
    // also in -viewDidLoad, we need to set the parent-child relationship early. No need to remove on -init failure, this will be done in
    // -dealloc
    objc_setAssociatedObject(viewController, s_popoverControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    return (*s_UIPopoverController__initWithContentViewController_Imp)(self, _cmd, viewController);
}

// Marked as __unsafe_unretained to avoid ARC inserting incorrect memory management calls leading to crashes for -dealloc
static void swizzled_UIPopoverController__dealloc_Imp(__unsafe_unretained UIPopoverController *self, SEL _cmd)
{
    objc_setAssociatedObject(self.contentViewController, s_popoverControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    (*s_UIPopoverController__dealloc_Imp)(self, _cmd);
}

static void swizzled_UIPopoverController__setContentViewController_animated_Imp(UIPopoverController *self, SEL _cmd, UIViewController *viewController, BOOL animated)
{
    // Remove the old association before creating the new one
    objc_setAssociatedObject(self.contentViewController, s_popoverControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    (*s_UIPopoverController__setContentViewController_animated_Imp)(self, _cmd, viewController, animated);
    objc_setAssociatedObject(viewController, s_popoverControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
}
