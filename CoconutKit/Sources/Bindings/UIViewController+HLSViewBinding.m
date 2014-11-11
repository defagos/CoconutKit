//
//  UIViewController+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "UIViewController+HLSViewBinding.h"

#import "HLSViewBindingDebugOverlayViewController.h"
#import "UIView+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIViewController+HLSExtensions.h"

@implementation UIViewController (HLSViewBinding)

#pragma mark Overlay

- (void)showBindingDebugOverlayViewRecursive:(BOOL)recursive
{
    [HLSViewBindingDebugOverlayViewController showForDebuggedViewController:self recursive:recursive];
}

#pragma mark Bindings

- (void)refreshBindings
{
    [[self viewIfLoaded] refreshBindings];
}

- (BOOL)checkDisplayedValuesWithError:(NSError **)pError
{
    return [[self viewIfLoaded] checkDisplayedValuesWithError:pError];
}

- (BOOL)updateModelWithError:(NSError **)pError
{
    return [[self viewIfLoaded] updateModelWithError:pError];
}

@end
