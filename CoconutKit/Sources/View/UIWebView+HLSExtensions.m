//
//  UIWebView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UIWebView+HLSExtensions.h"

@implementation UIWebView (HLSExtensions)

#pragma mark Accessors and mutators

- (BOOL)isTransparent
{
    return ! self.opaque && [self.backgroundColor isEqual:[UIColor clearColor]];
}

- (void)setTransparent:(BOOL)transparent
{
    self.opaque = ! transparent;
    self.backgroundColor = transparent ? [UIColor clearColor] : [UIWebView appearance].backgroundColor;
}

@end
