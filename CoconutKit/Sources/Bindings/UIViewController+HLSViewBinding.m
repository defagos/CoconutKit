//
//  UIViewController+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
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
