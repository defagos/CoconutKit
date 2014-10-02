//
//  UILabel+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UILabel+HLSViewBinding.h"

@implementation UILabel (HLSViewBindingImplementation)

#pragma mark HLSViewBindingImplementation protocol implementation

- (void)updateViewWithValue:(id)value
{
    self.text = value;
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
