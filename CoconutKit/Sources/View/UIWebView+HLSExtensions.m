//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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
