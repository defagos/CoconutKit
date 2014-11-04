//
//  UIActivityIndicatorView+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIActivityIndicatorView+HLSViewBinding.h"

@implementation UIActivityIndicatorView (HLSViewBinding)

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    if ([value boolValue]) {
        [self startAnimating];
    }
    else {
        [self stopAnimating];
    }
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
