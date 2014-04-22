//
//  UISegmentedControl+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 29/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UISegmentedControl+HLSViewBinding.h"

@implementation UISegmentedControl (HLSViewBindingImplementation)

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    self.selectedSegmentIndex = [value integerValue];
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
