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

- (void)updateBoundViewsAnimated:(BOOL)animated
{
    [[self viewIfLoaded] updateBoundViewsAnimated:animated];
}

- (BOOL)check:(BOOL)check andUpdate:(BOOL)update withCurrentInputValuesError:(NSError *__autoreleasing *)pError
{
    return [[self viewIfLoaded] check:check andUpdate:update withCurrentInputValuesError:pError];
}

@end
