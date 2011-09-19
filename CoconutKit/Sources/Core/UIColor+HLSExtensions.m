//
//  UIColor+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIColor+HLSExtensions.h"
#import "HLSCategoryLinker.h"

HLSLinkCategory(UIColor_HLSExtensions)

@implementation UIColor (HLSExtensions)

+ (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random() % 256) / 255.f
                           green:(arc4random() % 256) / 255.f 
                            blue:(arc4random() % 256) / 255.f 
                           alpha:1.f];
}

- (UIColor *)invertColor
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    UIColor *invertColor = [[[UIColor alloc] initWithRed:1.f - components[0]
                                                   green:1.f - components[1]
                                                    blue:1.f - components[2]
                                                   alpha:components[3]] autorelease];
    
    return invertColor;
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

- (NSUInteger)alphaComponent
{
    return (NSUInteger)roundf(255.f * [self normalizedAlphaComponent]);
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

- (CGFloat)normalizedAlphaComponent
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    return components[3];
}

@end
