//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIViewController+HLSViewBinding.h"

#import "UIView+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIViewController+HLSExtensions.h"

@implementation UIViewController (HLSViewBinding)

#pragma mark Bindings

- (void)updateBoundViewHierarchyAnimated:(BOOL)animated
{
    [[self viewIfLoaded] updateBoundViewHierarchyAnimated:animated];
}

- (void)updateBoundViewHierarchy
{
    [[self viewIfLoaded] updateBoundViewHierarchy];
}

- (BOOL)checkBoundViewHierarchyWithError:(NSError *__autoreleasing *)pError
{
    return [[self viewIfLoaded] checkBoundViewHierarchyWithError:pError];
}

@end
