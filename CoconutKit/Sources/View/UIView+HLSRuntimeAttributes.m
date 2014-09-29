//
//  UIView+HLSRuntimeAttributes.m
//  CoconutKit
//
//  Created by Samuel Défago on 1/26/13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSRuntimeAttributes.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "NSArray+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIColor+HLSExtensions.h"

// Keys for associated objects
static void *s_localizationTableNameKey = &s_localizationTableNameKey;
static void *s_localizationBundleNameKey = &s_localizationBundleNameKey;

// Method implementations
static void UIView__setColorFormat_Imp(UIView *self, SEL _cmd, NSString *colorFormat);

@implementation UIView (HLSRuntimeAttributes)

#pragma mark Class methods

+ (void)load
{
    // Inject KVC-compliant color setter methods on all UIView subclasses
    unsigned int numberOfClasses = 0;
    Class *classes = objc_copyClassList(&numberOfClasses);
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];
        if (! hls_class_isSubclassOfClass(class, objc_getClass("UIView"))) {
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
            NSString *methodName = [NSString stringWithCString:sel_getName(method_getName(method))
                                                      encoding:NSUTF8StringEncoding];
            if (! [methodName hasSuffix:@"Color:"] || ! [methodName hasPrefix:@"set"]) {
                continue;
            }
            
            SEL colorSetterSelector = NSSelectorFromString([methodName stringByReplacingCharactersInRange:NSMakeRange(0, 3)
                                                                                               withString:@"setHls"]);
            class_addMethod(class, colorSetterSelector, (IMP)UIView__setColorFormat_Imp, "v@:@");
        }
        free(methods);
    }
    free(classes);
}

#pragma mark Accessors and mutators

- (NSString *)locTable
{
    return objc_getAssociatedObject(self, s_localizationTableNameKey);
}

- (void)setLocTable:(NSString *)locTable
{
    objc_setAssociatedObject(self, s_localizationTableNameKey, locTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)locBundle
{
    return objc_getAssociatedObject(self, s_localizationBundleNameKey);
}

- (void)setLocBundle:(NSString *)locBundle
{
    objc_setAssociatedObject(self, s_localizationBundleNameKey, locBundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    
    NSString *colorSetterSelectorName = [NSString stringWithCString:sel_getName(_cmd) encoding:NSUTF8StringEncoding];
    SEL colorSelector = NSSelectorFromString([colorSetterSelectorName stringByReplacingOccurrencesOfString:@"setHls" withString:@"set"]);
    
    // Cannot use -performSelector here since the signature is not explicitly visible in the call for ARC to perform
    // correct memory management
    void (*methodImp)(id, SEL, id) = (void (*)(id, SEL, id))[self methodForSelector:colorSelector];
    methodImp(self, colorSelector, color);
}
