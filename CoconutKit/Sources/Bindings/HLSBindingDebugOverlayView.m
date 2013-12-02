//
//  HLSBindingsDebugOverlayView.m
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingDebugOverlayView.h"

#import "UIView+HLSExtensions.h"

@implementation HLSBindingDebugOverlayView

#pragma mark Object creation and destruction

- (id)initWithDebuggedViewController:(UIViewController *)debuggedViewController
{
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    if (self = [super initWithFrame:applicationFrame]) {
        self.autoresizingMask = HLSViewAutoresizingAll;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
    }
    return self;
}

- (id)init
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self initWithDebuggedViewController:rootViewController];
}

@end
