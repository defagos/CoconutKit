//
//  UIColor+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "UIColor+HLSExtensions.h"

#import "HLSLogger.h"
#import "NSObject+HLSExtensions.h"
#import <objc/runtime.h>

// Remark: Colors via user-defined runtime attributes are implemented in UIView+HLSRuntimeAttributes.m

@implementation UIColor (HLSExtensions)

#pragma mark Class methods

+ (UIColor *)colorWithNonNormalizedRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
{
    if (red > 255) {
        HLSLoggerWarn(@"Incorrect R component, larger than 255. Fixed to 255");
        red = 255;
    }
    if (green > 255) {
        HLSLoggerWarn(@"Incorrect G component, larger than 255. Fixed to 255");
        green = 255;
    }
    if (blue > 255) {
        HLSLoggerWarn(@"Incorrect B component, larger than 255. Fixed to 255");
        blue = 255;
    }
    return [self colorWithRed:red / 255.f green:green / 255.f blue:blue / 255.f alpha:alpha];
}

+ (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random() % 256) / 255.f
                           green:(arc4random() % 256) / 255.f 
                            blue:(arc4random() % 256) / 255.f 
                           alpha:1.f];
}

+ (UIColor *)colorWithName:(NSString *)name
{    
    SEL selector = NSSelectorFromString([name stringByAppendingString:@"Color"]);
    Method method = class_getClassMethod(self, selector);
    if (! method) {
        HLSLoggerWarn(@"No color %@ name was found on class %@", name, [self className]);
        return nil;
    }
    
    id (*implementation)(id, SEL) = (id (*)(id, SEL))method_getImplementation(method);
    id color = (*implementation)(self, selector);
    if (! [color isKindOfClass:[UIColor class]]) {
        HLSLoggerWarn(@"The name %@ does not correspond to a color for class %@", name, [self className]);
        return nil;
    }
    
    return color;
}

- (UIColor *)invertedColor
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    UIColor *invertedColor = [[UIColor alloc] initWithRed:1.f - components[0]
                                                    green:1.f - components[1]
                                                     blue:1.f - components[2]
                                                    alpha:components[3]];
    
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
