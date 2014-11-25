//
//  UISplitViewController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/31/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UISplitViewController+HLSExtensions.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_autorotationModeKey = &s_autorotationModeKey;

// Original implementation of the methods we swizzle
static BOOL (*s_UISplitViewController__shouldAutorotate_Imp)(id, SEL) = NULL;
static NSUInteger (*s_UISplitViewController__supportedInterfaceOrientations_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzled_UISplitViewController__shouldAutorotate_Imp(UISplitViewController *self, SEL _cmd);
static NSUInteger swizzled_UISplitViewController__supportedInterfaceOrientations_Imp(UISplitViewController *self, SEL _cmd);

@implementation UISplitViewController (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    // No swizzling occurs on iOS < 6 since those two methods do not exist
    s_UISplitViewController__shouldAutorotate_Imp = (BOOL (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                                 @selector(shouldAutorotate),
                                                                                                 (IMP)swizzled_UISplitViewController__shouldAutorotate_Imp);
    s_UISplitViewController__supportedInterfaceOrientations_Imp = (NSUInteger (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                                                     @selector(supportedInterfaceOrientations),
                                                                                                                     (IMP)swizzled_UISplitViewController__supportedInterfaceOrientations_Imp);
}

#pragma mark Accessors and mutators

- (HLSAutorotationMode)autorotationMode
{
    NSNumber *autorotationModeNumber = hls_getAssociatedObject(self, s_autorotationModeKey);
    if (! autorotationModeNumber) {
        return HLSAutorotationModeContainer;
    }
    else {
        return [autorotationModeNumber integerValue];
    }
}

- (void)setAutorotationMode:(HLSAutorotationMode)autorotationMode
{
    hls_setAssociatedObject(self, s_autorotationModeKey, @(autorotationMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

static BOOL swizzled_UISplitViewController__shouldAutorotate_Imp(UISplitViewController *self, SEL _cmd)
{
    // The container always decides first (does not look at children)
    if (! (*s_UISplitViewController__shouldAutorotate_Imp)(self, _cmd)) {
        return NO;
    }
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren:
        case HLSAutorotationModeContainerAndTopChildren: {
            for (UIViewController *viewController in self.viewControllers) {
                if (! [viewController shouldAutorotate]) {
                    return NO;
                }
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

static NSUInteger swizzled_UISplitViewController__supportedInterfaceOrientations_Imp(UISplitViewController *self, SEL _cmd)
{
    // The container always decides first (does not look at children)
    NSUInteger containerSupportedInterfaceOrientations = (*s_UISplitViewController__supportedInterfaceOrientations_Imp)(self, _cmd);
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren:
        case HLSAutorotationModeContainerAndTopChildren: {
            for (UIViewController *viewController in self.viewControllers) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
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
