//
//  UIColor+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIColor+HLSExtensions.h"

@implementation UIColor (HLSExtensions)

+ (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random() % 256) / 255.f
                           green:(arc4random() % 256) / 255.f 
                            blue:(arc4random() % 256) / 255.f 
                           alpha:1.f];
}

- (UIColor *)invertedColor
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    UIColor *invertedColor = [[[UIColor alloc] initWithRed:1.f - components[0]
                                                   green:1.f - components[1]
                                                    blue:1.f - components[2]
                                                   alpha:components[3]] autorelease];
    
    return invertedColor;
}

#pragma mark Color components

- (NSUInteger)redComponent
{
    return (NSUInteger)roundf(255.f * [self normalizedRedComponent]);
}

- (NSUInteger)greenComponent
{
    return (NSUInteger)roundf(255.f * [self normalizedGreenComponent]);
}

- (NSUInteger)blueComponent
{
    return (NSUInteger)roundf(255.f * [self normalizedBlueComponent]);
}

- (CGFloat)normalizedRedComponent
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    return components[0];
}

- (CGFloat)normalizedGreenComponent
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    return components[1];
}

- (CGFloat)normalizedBlueComponent
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    return components[2];
}

@end
