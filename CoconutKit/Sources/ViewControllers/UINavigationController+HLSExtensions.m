//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UINavigationController+HLSExtensions.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_autorotationModeKey = &s_autorotationModeKey;
static void *s_forwardingStatusBarStyleKey = &s_forwardingStatusBarStyleKey;

// Original implementation of the methods we swizzle
static BOOL (*s_shouldAutorotate)(id, SEL) = NULL;
static NSUInteger (*s_supportedInterfaceOrientations)(id, SEL) = NULL;
static UIStatusBarStyle (*s_preferredStatusBarStyle)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzle_shouldAutorotate(UINavigationController *self, SEL _cmd);
static NSUInteger swizzle_supportedInterfaceOrientations(UINavigationController *self, SEL _cmd);
static UIStatusBarStyle swizzle_preferredStatusBarStyle(UINavigationController *self, SEL _cmd);

@implementation UINavigationController (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(shouldAutorotate), swizzle_shouldAutorotate, &s_shouldAutorotate);
    HLSSwizzleSelector(self, @selector(supportedInterfaceOrientations), swizzle_supportedInterfaceOrientations, &s_supportedInterfaceOrientations);
    HLSSwizzleSelector(self, @selector(preferredStatusBarStyle), swizzle_preferredStatusBarStyle, &s_preferredStatusBarStyle);
}

#pragma mark Accessors and mutators

- (HLSAutorotationMode)autorotationMode
{
    NSNumber *autorotationModeNumber = hls_getAssociatedObject(self, s_autorotationModeKey);
    if (! autorotationModeNumber) {
        return HLSAutorotationModeContainer;
    }
    else {
        return autorotationModeNumber.integerValue;
    }
}

- (void)setAutorotationMode:(HLSAutorotationMode)autorotationMode
{
    hls_setAssociatedObject(self, s_autorotationModeKey, @(autorotationMode), HLS_ASSOCIATION_STRONG_NONATOMIC);
}

- (BOOL)isForwardingStatusBarStyle
{
    NSNumber *forwardingStatusBarStyleNumber = hls_getAssociatedObject(self, s_forwardingStatusBarStyleKey);
    if (! forwardingStatusBarStyleNumber) {
        return NO;
    }
    else {
        return forwardingStatusBarStyleNumber.boolValue;
    }
}

- (void)setForwardingStatusBarStyle:(BOOL)forwardingStatusBarStyle
{
    hls_setAssociatedObject(self, s_forwardingStatusBarStyleKey, @(forwardingStatusBarStyle), HLS_ASSOCIATION_STRONG_NONATOMIC);
}

@end

static BOOL swizzle_shouldAutorotate(UINavigationController *self, SEL _cmd)
{
    // The container always decides first (does not look at children)
    if (! s_shouldAutorotate(self, _cmd)) {
        return NO;
    }
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren: {
            for (UIViewController *viewController in [self.viewControllers reverseObjectEnumerator]) {
                if (! [viewController shouldAutorotate]) {
                    return NO;
                }
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndTopChildren: {
            if (! [self.topViewController shouldAutorotate]) {
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

static NSUInteger swizzle_supportedInterfaceOrientations(UINavigationController *self, SEL _cmd)
{
    // The container always decides first (does not look at children)
    NSUInteger containerSupportedInterfaceOrientations = s_supportedInterfaceOrientations(self, _cmd);
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren: {
            for (UIViewController *viewController in [self.viewControllers reverseObjectEnumerator]) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndTopChildren: {
            containerSupportedInterfaceOrientations &= [self.topViewController supportedInterfaceOrientations];
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

// Only -preferredStatusBarStyle can be swizzled (and this suffices, other methods are called automatically
// as children are pushed to and popped from the navigation controller)
static UIStatusBarStyle swizzle_preferredStatusBarStyle(UINavigationController *self, SEL _cmd)
{
    if (self.forwardingStatusBarStyle && self.topViewController) {
        return [self.topViewController preferredStatusBarStyle];
    }
    else {
        return s_preferredStatusBarStyle(self, _cmd);
    }
}
