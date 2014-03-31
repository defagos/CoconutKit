//
//  UITextView+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UITextView+HLSViewBinding.h"

@implementation UITextView (HLSViewBinding)

#pragma mark HLSViewBinding protocol implementation

- (void)updateViewWithValue:(id)value
{
    self.text = value;
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
