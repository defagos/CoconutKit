//
//  UIProgressView+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UIProgressView+HLSViewBinding.h"

@implementation UIProgressView (HLSViewBindingImplementation)

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    self.progress = [value floatValue];
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
