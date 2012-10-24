//
//  UITabBarController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UITabBarController+HLSExtensions.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_autorotationModeKey = &s_autorotationModeKey;

// Original implementation of the methods we swizzle
static BOOL (*s_UITabBarController__shouldAutorotate_Imp)(id, SEL) = NULL;
static NSUInteger (*s_UITabBarController__supportedInterfaceOrientations_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzled_UITabBarController__shouldAutorotate_Imp(UITabBarController *self, SEL _cmd);
static NSUInteger swizzled_UITabBarController__supportedInterfaceOrientations_Imp(UITabBarController *self, SEL _cmd);
static BOOL swizzled_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp(UITabBarController *self, SEL _cmd, NSInteger toInterfaceOrientation);

@implementation UITabBarController (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    // No swizzling occurs on iOS < 6 since those two methods do not exist
    s_UITabBarController__shouldAutorotate_Imp = (BOOL (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                       @selector(shouldAutorotate),
                                                                                       (IMP)swizzled_UITabBarController__shouldAutorotate_Imp);
    s_UITabBarController__supportedInterfaceOrientations_Imp = (NSUInteger (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                                           @selector(supportedInterfaceOrientations),
                                                                                                           (IMP)swizzled_UITabBarController__supportedInterfaceOrientations_Imp);
    
    // Swizzled both on iOS < 6 and iOS 6
    HLSSwizzleSelector(self,
                       @selector(shouldAutorotateToInterfaceOrientation:),
                       (IMP)swizzled_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp);
}

#pragma mark Accessors and mutators

- (HLSAutorotationMode)autorotationMode
{
    NSNumber *autorotationModeNumber = objc_getAssociatedObject(self, s_autorotationModeKey);
    if (! autorotationModeNumber) {
        return HLSAutorotationModeContainer;
    }
    else {
        return [autorotationModeNumber integerValue];
    }
}

- (void)setAutorotationMode:(HLSAutorotationMode)autorotationMode
{
    objc_setAssociatedObject(self, s_autorotationModeKey, [NSNumber numberWithInteger:autorotationMode], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

// Swizzled on iOS 6 only, never called on iOS 4 and 5
static BOOL swizzled_UITabBarController__shouldAutorotate_Imp(UITabBarController *self, SEL _cmd)
{
    // On iOS 6, the container always decides first (does not look at children)
    BOOL containerShouldAutorotate = (*s_UITabBarController__shouldAutorotate_Imp)(self, _cmd);
    if (! containerShouldAutorotate) {
        return NO;
    }
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndChildren:
        case HLSAutorotationModeContainerAndVisibleChildren: {
            for (UIViewController *viewController in self.viewControllers) {
                if (! viewController.shouldAutorotate) {
                    return NO;
                }
            }
            break;
        }
            
        case HLSAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return containerShouldAutorotate;
}

// Swizzled on iOS 6 only, never called on iOS 4 and 5 by UIKit (can be called by client code, though)
static NSUInteger swizzled_UITabBarController__supportedInterfaceOrientations_Imp(UITabBarController *self, SEL _cmd)
{
    // On iOS 6, the container always decides first (does not look at children)
    BOOL containerSupportedInterfaceOrientations = (*s_UITabBarController__supportedInterfaceOrientations_Imp)(self, _cmd);
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndChildren:
        case HLSAutorotationModeContainerAndVisibleChildren: {
            for (UIViewController *viewController in self.viewControllers) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
            break;
        }
            
        case HLSAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return containerSupportedInterfaceOrientations;
}

// Swizzled on iOS 6 as well, but never called by UIKit (can be called by client code, though)
static BOOL swizzled_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp(UITabBarController *self, SEL _cmd, NSInteger toInterfaceOrientation)
{
    // Pre-iOS 6: Strange behavior of the original UITabBarController implementation, which never calls the -shouldAutorotateToInterfaceOrientation:
    //            for the top view controller when swizzled (have a look at the disassembly). To fix this, we assume the tab bar controller returns
    //            YES for all orientations, and we do not call the original implementation. This can lead to issues if UITabBarController is subclassed
    //            to restrict the supported orientation set, but:
    //              - orientation should be given by the top view controller
    //              - iOS 4 and iOS 5 will soon disappear, this fix is temporary and should never be a problem in practice
    
    // Same logic for all cases
    for (UIViewController *viewController in [self.viewControllers reverseObjectEnumerator]) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    
    return YES;
}
