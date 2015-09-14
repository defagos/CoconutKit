//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UISplitViewController+HLSExtensions.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_autorotationModeKey = &s_autorotationModeKey;

// Original implementation of the methods we swizzle
static BOOL (*s_shouldAutorotate)(id, SEL) = NULL;
static NSUInteger (*s_supportedInterfaceOrientations)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzle_shouldAutorotate(UISplitViewController *self, SEL _cmd);
static NSUInteger swizzle_supportedInterfaceOrientations(UISplitViewController *self, SEL _cmd);

@implementation UISplitViewController (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    // No swizzling occurs on iOS < 6 since those two methods do not exist
    HLSSwizzleSelector(self, @selector(shouldAutorotate), swizzle_shouldAutorotate, &s_shouldAutorotate);
    HLSSwizzleSelector(self, @selector(supportedInterfaceOrientations), swizzle_supportedInterfaceOrientations, &s_supportedInterfaceOrientations);
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

static BOOL swizzle_shouldAutorotate(UISplitViewController *self, SEL _cmd)
{
    // The container always decides first (does not look at children)
    if (! s_shouldAutorotate(self, _cmd)) {
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

static NSUInteger swizzle_supportedInterfaceOrientations(UISplitViewController *self, SEL _cmd)
{
    // The container always decides first (does not look at children)
    NSUInteger containerSupportedInterfaceOrientations = s_supportedInterfaceOrientations(self, _cmd);
    
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
