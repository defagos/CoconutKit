//
//  UIImageView+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIImageView+HLSViewBinding.h"

@implementation UIImageView (HLSViewBinding)

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[UIImage class], [NSString class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    if ([value isKindOfClass:[UIImage class]]) {
        self.image = value;
    }
    else {
        UIImage *image = [UIImage imageNamed:value];
        if (! image) {
            image = [UIImage imageWithContentsOfFile:value];
        }
        self.image = image;
    }
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
