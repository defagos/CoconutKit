//
//  UITextField+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UITextField+HLSViewBinding.h"

@implementation UITextField (HLSViewBindingImplementation)

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
