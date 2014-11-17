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

- (void)refreshBindings
{
    [[self viewIfLoaded] refreshBindings];
}

- (BOOL)checkInputValuesWithError:(NSError **)pError
{
    return [[self viewIfLoaded] checkInputValuesWithError:pError];
}

- (BOOL)updateModelWithError:(NSError **)pError
{
    return [[self viewIfLoaded] updateModelWithError:pError];
}

- (BOOL)checkAndUpdateModelWithInputValuesError:(NSError *__autoreleasing *)pError
{
    return [[self viewIfLoaded] checkAndUpdateModelWithInputValuesError:pError];
}

@end
