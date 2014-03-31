//
//  UISwitch+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "UISwitch+HLSViewBinding.h"

@implementation UISwitch (HLSViewBinding)

#pragma mark HLSViewBinding protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value
{
    self.on = [value boolValue];
}

- (BOOL)bindsSubviewsRecursively
{
    return NO;
}

@end
