//
//  UIWindow+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIWindow+HLSExtensions.h"

@implementation UIWindow (HLSExtensions)

#pragma mark Accessors and mutators

- (UIViewController *)activeViewController
{
    return self.rootViewController.presentedViewController ?: self.rootViewController;
}

@end
