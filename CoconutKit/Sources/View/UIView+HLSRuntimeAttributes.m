//
//  UIView+HLSRuntimeAttributes.m
//  CoconutKit
//
//  Created by Samuel Défago on 1/26/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIView+HLSRuntimeAttributes.h"

#import "HLSRuntime.h"

// Keys for associated objects
static void *s_localizationTableNameKey = &s_localizationTableNameKey;
static void *s_localizationBundleNameKey = &s_localizationBundleNameKey;

// Original implementations of the methods we swizzle
static void (*s_UIView__awakeFromNib_Imp)(id, SEL) = NULL;

// Helper functions
static void injectColorNameMethods(Class cls);

// Swizzled method implementations
static void swizzled_UIView__awakeFromNib_Imp(UIView *self, SEL _cmd);

// Method implementations
static NSString * UIView__colorName_Imp(UIView *self, SEL _cmd);
static void UIView__setColorName_Imp(UIView *self, SEL _cmd, NSString *colorName);

@implementation UIView (HLSRuntimeAttributes)

#pragma mark Class methods

+ (void)load
{
    s_UIView__awakeFromNib_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, @selector(awakeFromNib), (IMP)swizzled_UIView__awakeFromNib_Imp);
    
    // Inject color name methods on all UIView subclasses
    unsigned int numberOfClasses = 0;
    Class *classes = objc_copyClassList(&numberOfClasses);
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];
        if (HLSIsSubclassOfClass(class, objc_getClass("UIView"))) {
            injectColorNameMethods(class);
        }
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

#pragma mark Helper functions

// TODO: Should avoid ObjC code in this method (called from +load)
static void injectColorNameMethods(Class cls)
{
    // No identity test here. We want to perform color method lookup for each class in the UIView class hierarchy
    // (the class_copyMethodList function only returns methods defined by the class itself, not by one of its
    // superclasses)
    unsigned int numberOfMethods = 0;
    Method *methods = class_copyMethodList(cls, &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; ++i) {
        Method method = methods[i];
        
        // Look for methods ending in "Color"
        NSString *methodName = [NSString stringWithCString:sel_getName(method_getName(method)) encoding:NSUTF8StringEncoding];
        if (! [methodName hasSuffix:@"Color"]) {
            continue;
        }
        
        // The method must have a corresponding setter
        NSString *capitalizedMethodName = [methodName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                              withString:[[methodName substringToIndex:1] capitalizedString]];
        SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@:", capitalizedMethodName]);
        Method setterMethod = class_getInstanceMethod(cls, setterSelector);
        if (! setterMethod) {
            continue;
        }
        
        // Add methods to get and set the corresponding color name as user-defined runtime attribute
        SEL colorGetterSelector = NSSelectorFromString([NSString stringWithFormat:@"hls%@", capitalizedMethodName]);
        class_addMethod(cls, colorGetterSelector, (IMP)UIView__colorName_Imp, "@@:");
        
        SEL colorSetterSelector = NSSelectorFromString([NSString stringWithFormat:@"setHls%@:", capitalizedMethodName]);
        class_addMethod(cls, colorSetterSelector, (IMP)UIView__setColorName_Imp, "v@:@");
    }
    free(methods);
}

#pragma mark Swizzled method implementations

static void swizzled_UIView__awakeFromNib_Imp(UIView *self, SEL _cmd)
{
    // TODO: Loop over attributes and set them
    
    (*s_UIView__awakeFromNib_Imp)(self, _cmd);
}

#pragma mark Method implementations

static NSString *UIView__colorName_Imp(UIView *self, SEL _cmd)
{
    return nil;
}

static void UIView__setColorName_Imp(UIView *self, SEL _cmd, NSString *colorName)
{
    NSLog(@"----> set color to %@", colorName);
}
