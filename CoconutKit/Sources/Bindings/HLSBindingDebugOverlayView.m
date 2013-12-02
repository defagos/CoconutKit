//
//  HLSBindingsDebugOverlayView.m
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingDebugOverlayView.h"

#import "HLSAssert.h"
#import "UIView+HLSViewBindingFriend.h"
#import "UIView+HLSExtensions.h"

@interface HLSBindingDebugOverlayView ()

@property (nonatomic, weak) UIViewController *debuggedViewController;

@end

@implementation HLSBindingDebugOverlayView

#pragma mark Object creation and destruction

- (id)initWithDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive
{
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    if (self = [super initWithFrame:applicationFrame]) {
        self.autoresizingMask = HLSViewAutoresizingAll;
        self.alpha = 0.f;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
        self.debuggedViewController = debuggedViewController;
        
        UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        [self addGestureRecognizer:gestureRecognizer];
        
        [self refreshDebugInformationForBindingsInView:debuggedViewController.view recursive:recursive];
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Debug information display

- (void)show
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController.view addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.f;
    }];
}

- (void)refreshDebugInformationForBindingsInView:(UIView *)view recursive:(BOOL)recursive
{
    if (! recursive && view.nearestViewController != self.debuggedViewController) {
        return;
    }
    
    HLSViewBindingInformation *bindingInformation = view.bindingInformation;
    if (bindingInformation) {
        UIView *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlayButton.frame = [view convertRect:view.bounds toView:self];
        overlayButton.layer.borderColor = bindingInformation.verified ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
        overlayButton.layer.borderWidth = 2.f;
        [self addSubview:overlayButton];
    }
    
    for (UIView *subview in view.subviews) {
        [self refreshDebugInformationForBindingsInView:subview recursive:recursive];
    }
}

#pragma mark Actions

- (void)close:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
