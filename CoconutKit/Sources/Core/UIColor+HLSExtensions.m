//
//  UIColor+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "UIColor+HLSExtensions.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"

// Method implementations
static void UIView__setColorFormat_Imp(UIView *self, SEL _cmd, NSString *colorFormat);

@interface UIView (HLSColorNameRuntimeAttributes)

@end

@implementation UIColor (HLSExtensions)

#pragma mark Class methods

+ (instancetype)colorWithNonNormalizedRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
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

+ (instancetype)randomColor
{
    return [UIColor colorWithRed:arc4random_uniform(256) / 255.f
                           green:arc4random_uniform(256) / 255.f
                            blue:arc4random_uniform(256) / 255.f
                           alpha:1.f];
}

+ (instancetype)colorWithName:(NSString *)name
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

@implementation UIView (HLSColorNameRuntimeAttributes)

#pragma mark Class methods

+ (void)load
{
    // Inject KVC-compliant color setter methods on all UIView subclasses
    unsigned int numberOfClasses = 0;
    Class *classes = objc_copyClassList(&numberOfClasses);
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];
        if (! hls_class_isSubclassOfClass(class, [UIView class])) {
            continue;
        }
        
        // The class_copyMethodList extracts only methods defined by the class itself, not by its superclasses
        unsigned int numberOfMethods = 0;
        Method *methods = class_copyMethodList(class, &numberOfMethods);
        for (unsigned int i = 0; i < numberOfMethods; ++i) {
            Method method = methods[i];
            
            // Find setters with proper number of arguments (one argument besides the usual id and SEL)
            if (method_getNumberOfArguments(method) != 3) {
                continue;
            }
            
            // Look for KVC-compliant setters ending in "Color"
            NSString *methodName = @(sel_getName(method_getName(method)));
            if (! [methodName hasSuffix:@"Color:"] || ! [methodName hasPrefix:@"set"]) {
                continue;
            }
            
            SEL colorSetterSelector = NSSelectorFromString([methodName stringByReplacingOccurrencesOfString:@":" withString:@"Name:"]);
            class_addMethod(class, colorSetterSelector, (IMP)UIView__setColorFormat_Imp, "v@:@");
        }
        free(methods);
    }
    free(classes);
}

@end

#pragma mark Method implementations

// Common setter implementation for setting colors by name
static void UIView__setColorFormat_Imp(UIView *self, SEL _cmd, NSString *colorFormat)
{
    if (! [colorFormat isFilled]) {
        HLSLoggerWarn(@"No value has been set for attribute %s of %@. Skipped", sel_getName(_cmd), self);
        return;
    }
    
    NSArray *colorFormatComponents = [colorFormat componentsSeparatedByString:@":"];
    if ([colorFormatComponents count] > 2) {
        HLSLoggerWarn(@"Invalid syntax for attribute %s of %@ (expect className:colorName). Skipped", sel_getName(_cmd), self);
        return;
    }
    
    NSString *className = nil;
    NSString *colorName = nil;
    if ([colorFormatComponents count] == 2) {
        className = [colorFormatComponents firstObject];
        colorName = [colorFormatComponents lastObject];
    }
    else {
        colorName = [colorFormatComponents firstObject];
    }
    
    Class colorClass = Nil;
    if (className) {
        colorClass = NSClassFromString(className);
        if (! colorClass) {
            HLSLoggerWarn(@"The class %@ does not exist. Skipped", className);
            return;
        }
        
        if (! hls_class_isSubclassOfClass(colorClass, [UIColor class])) {
            HLSLoggerWarn(@"The class %@ is not a subclass of UIColor. Skipped", className);
            return;
        }
    }
    else {
        colorClass = [UIColor class];
    }
    
    UIColor *color = [colorClass colorWithName:colorName];
    if (! color) {
        return;
    }
    
    NSString *colorSetterSelectorName = @(sel_getName(_cmd));
    SEL colorSelector = NSSelectorFromString([colorSetterSelectorName stringByReplacingOccurrencesOfString:@"Name:" withString:@":"]);
    
    // Cannot use -performSelector here since the signature is not explicitly visible in the call for ARC to perform
    // correct memory management
    void (*methodImp)(id, SEL, id) = (void (*)(id, SEL, id))[self methodForSelector:colorSelector];
    methodImp(self, colorSelector, color);
}
