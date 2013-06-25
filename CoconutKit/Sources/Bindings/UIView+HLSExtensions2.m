//
//  UIView+HLSExtensions2.m
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIView+HLSExtensions2.h"

@implementation UIView (HLSExtensions2)

- (UIViewController *)viewController
{
    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)self.nextResponder;
    }
    else {
        return nil;
    }
}

- (UIViewController *)nearestViewController
{
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}

@end
