//
//  UINavigationController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UINavigationController+HLSExtensions.h"

#import "HLSAutorotationCompatibility.h"
#import "HLSRuntime.h"

// Associated object keys
static void *s_autorotationModeKey = &s_autorotationModeKey;

// Original implementation of the methods we swizzle
static BOOL (*s_UINavigationController__shouldAutorotate_Imp)(id, SEL) = NULL;
static NSUInteger (*s_UINavigationController__supportedInterfaceOrientations_Imp)(id, SEL) = NULL;
static BOOL (*s_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp)(id, SEL, NSInteger) = NULL;

// Swizzled method implementations
static BOOL swizzled_UINavigationController__shouldAutorotate_Imp(UINavigationController *self, SEL _cmd);
static NSUInteger swizzled_UINavigationController__supportedInterfaceOrientations_Imp(UINavigationController *self, SEL _cmd);
static BOOL swizzled_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp(UINavigationController *self, SEL _cmd, NSInteger toInterfaceOrientation);

@implementation UINavigationController (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    // No swizzling occurs on iOS < 6 since those two methods do not exist
    s_UINavigationController__shouldAutorotate_Imp = (BOOL (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                           @selector(shouldAutorotate),
                                                                                           (IMP)swizzled_UINavigationController__shouldAutorotate_Imp);
    s_UINavigationController__supportedInterfaceOrientations_Imp = (NSUInteger (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                                               @selector(supportedInterfaceOrientations),
                                                                                                               (IMP)swizzled_UINavigationController__supportedInterfaceOrientations_Imp);
    
    // Swizzled both on iOS < 6 and iOS 6
    s_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp = (BOOL (*)(id, SEL, NSInteger))HLSSwizzleSelector(self,
                                                                                                                            @selector(shouldAutorotateToInterfaceOrientation:),
                                                                                                                            (IMP)swizzled_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp);
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
static BOOL swizzled_UINavigationController__shouldAutorotate_Imp(UINavigationController *self, SEL _cmd)
{
    // On iOS 6, the container always decides first (does not look at children)
    if (! (*s_UINavigationController__shouldAutorotate_Imp)(self, _cmd)) {
        return NO;
    }
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren: {
            for (UIViewController<HLSAutorotationCompatibility> *viewController in [self.viewControllers reverseObjectEnumerator]) {
                if (! [viewController shouldAutorotate]) {
                    return NO;
                }
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndTopChildren: {
            UIViewController<HLSAutorotationCompatibility> *topViewController = (UIViewController<HLSAutorotationCompatibility> *)self.topViewController;
            if (! [topViewController shouldAutorotate]) {
                return NO;
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndNoChildren:
        case HLSAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return YES;
}

// Swizzled on iOS 6 only, never called on iOS 4 and 5 by UIKit (can be called by client code, though)
static NSUInteger swizzled_UINavigationController__supportedInterfaceOrientations_Imp(UINavigationController *self, SEL _cmd)
{
    // On iOS 6, the container always decides first (does not look at children)
    BOOL containerSupportedInterfaceOrientations = (*s_UINavigationController__supportedInterfaceOrientations_Imp)(self, _cmd);
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren: {
            for (UIViewController<HLSAutorotationCompatibility> *viewController in [self.viewControllers reverseObjectEnumerator]) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndTopChildren: {
            UIViewController<HLSAutorotationCompatibility> *topViewController = (UIViewController<HLSAutorotationCompatibility> *)self.topViewController;
            containerSupportedInterfaceOrientations &= [topViewController supportedInterfaceOrientations];
            break;
        }
            
        case HLSAutorotationModeContainerAndNoChildren:
        case HLSAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return containerSupportedInterfaceOrientations;
}

// Swizzled on iOS 6 as well, but never called by UIKit (can be called by client code, though)
static BOOL swizzled_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp(UINavigationController *self, SEL _cmd, NSInteger toInterfaceOrientation)
{
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren: {
            for (UIViewController *viewController in [self.viewControllers reverseObjectEnumerator]) {
                if (! [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
                    return NO;
                }
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndTopChildren: {
            if (self.topViewController && ! [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
                return NO;
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndNoChildren: {
            break;
        }
            
            
        case HLSAutorotationModeContainer:
        default: {
            return (*s_UINavigationController__shouldAutorotateToInterfaceOrientation_Imp)(self, _cmd, toInterfaceOrientation);
            break;
        }
    }
    
    return YES;
}
