//
//  UISlider+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 16/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UISlider+HLSViewBinding.h"

@implementation UISlider (HLSViewBinding)

#pragma mark HLSViewBinding protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    self.value = [value floatValue];
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
