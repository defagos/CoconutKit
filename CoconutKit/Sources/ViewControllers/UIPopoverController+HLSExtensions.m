//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIPopoverController+HLSExtensions.h"

#import "HLSRuntime.h"
#import "UIViewController+HLSExtensions.h"

// TODO: Remove when CoconutKit requires iOS >= 8 (which introdueced -popoverPresentationController)

// Associated object keys
static void *s_popoverControllerKey = &s_popoverControllerKey;

// Original implementation of the methods we swizzle
static id (*s_initWithContentViewController)(id, SEL, id) = NULL;
static void (*s_setContentViewController_animated)(id, SEL, id, BOOL) = NULL;

// Swizzled method implementations
static id swizzle_initWithContentViewController(UIPopoverController *self, SEL _cmd, UIViewController *viewController);
static void swizzle_setContentViewController_animated(UIPopoverController *self, SEL _cmd, UIViewController *viewController, BOOL animated);

@interface UIPopoverController (HLSExtensionsPrivate)

// Currently empty. Just used for method swizzling

@end

@implementation UIPopoverController (HLSExtensionsPrivate)

+ (void)load
{
    // initWithContentViewController: sadly does not rely on setContentViewController:animated: to set its content view controller. Must
    // swizzle it as well
    HLSSwizzleSelector(self, @selector(initWithContentViewController:), swizzle_initWithContentViewController, &s_initWithContentViewController);
    HLSSwizzleSelector(self, @selector(setContentViewController:animated:), swizzle_setContentViewController_animated, &s_setContentViewController_animated);
}

@end

@implementation UIViewController (UIPopoverController_HLSExtensions)

- (UIPopoverController *)popoverController
{
    UIPopoverController *popoverController = hls_getAssociatedObject(self, s_popoverControllerKey);
    if (popoverController) {
        return popoverController;
    }
    else {
        return self.parentViewController.popoverController;
    }
}

@end

static id swizzle_initWithContentViewController(UIPopoverController *self, SEL _cmd, UIViewController *viewController)
{
    // The -viewDidLoad method is triggered from the -initWithContentViewController method. If we want the parent information to be available
    // also in -viewDidLoad, we need to set the parent-child relationship early
    hls_setAssociatedObject(viewController, s_popoverControllerKey, self, HLS_ASSOCIATION_WEAK_NONATOMIC);
    return s_initWithContentViewController(self, _cmd, viewController);
}

static void swizzle_setContentViewController_animated(UIPopoverController *self, SEL _cmd, UIViewController *viewController, BOOL animated)
{
    // Remove the old association before creating the new one
    hls_setAssociatedObject(self.contentViewController, s_popoverControllerKey, nil, HLS_ASSOCIATION_WEAK_NONATOMIC);
    s_setContentViewController_animated(self, _cmd, viewController, animated);
    hls_setAssociatedObject(viewController, s_popoverControllerKey, self, HLS_ASSOCIATION_WEAK_NONATOMIC);
}
