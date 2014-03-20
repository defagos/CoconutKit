//
//  HLSViewBindingInformation.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSViewBindingInformation.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"

#import <objc/runtime.h>

@interface HLSViewBindingInformation ()

@property (nonatomic, weak) id object;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, strong) NSString *formatterName;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, weak) id formattingTarget;
@property (nonatomic, assign) SEL formattingSelector;
@property (nonatomic, strong) NSString *errorDescription;

@property (nonatomic, assign, getter=isVerified) BOOL verified;

@end

@implementation HLSViewBindingInformation

#pragma mark Object creation and destruction

- (id)initWithObject:(id)object keyPath:(NSString *)keyPath formatterName:(NSString *)formatterName view:(UIView *)view
{
    if (self = [super init]) {
        if (! [keyPath isFilled] || ! view) {
            HLSLoggerError(@"Binding requires at least a keypath and a view");
            return nil;
        }
        
        self.object = object;
        self.keyPath = keyPath;
        self.formatterName = formatterName;
        self.view = view;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Accessors and mutators

- (id)value
{
    // Lazily check and fill binding information
    if (! self.verified) {
        self.verified = [self verifyBindingInformation];
        if (! self.verified) {
            return nil;
        }
    }
            
    id value = [self.object valueForKeyPath:self.keyPath];
    if (self.formattingTarget) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self.formattingTarget performSelector:self.formattingSelector withObject:value];
#pragma clang diagnostic pop
    }
    else {
        return value;
    }
}

#pragma mark Binding

// Return YES if the binding information can be verified (keypath is valid, and any required formatting
// method could be located). If the information is valid but cannot not be fully checked (the keypath is
// correct, but returns nil), or if it is invalid, returns NO
- (BOOL)verifyBindingInformation
{
    // Just to check whether unnecessary verifications are made
    HLSLoggerDebug(@"Verifying binding information for %@", self);
    
    // An object has been provided. Check that the keypath is valid for it
    if (self.object) {
        @try {
            [self.object valueForKeyPath:self.keyPath];
        }
        @catch (NSException *exception) {
            self.errorDescription = @"The specified keypath is invalid for the bound object";
            return NO;
        }
    }
    // No object provided. Walk along the responder chain to find a responder matching the keypath (might be nil)
    else {
        self.object = [HLSViewBindingInformation bindingTargetForKeyPath:self.keyPath view:self.view];
    }
    
    if (! self.object) {
        self.errorDescription = @"No meaningful target was found along the responder chain for the specified keypath";
        return NO;
    }
    
    // No need to check for exceptions here, the keypath is here guaranteed to be valid for the object
    id value = [self.object valueForKeyPath:self.keyPath];
    
    // Formatter lookup
    __block id formattingTarget = nil;
    __block SEL formattingSelector = NULL;
    
    if ([self.formatterName isFilled]) {
        // Check whether the formatter is a class method +[ClassName methodName:]
        // Regex: ^\s*\+\s*\[(\w*)\s*(\w*:)\]\s*$
        NSString *pattern = @"^\\s*\\+\\s*\\[(\\w*)\\s*(\\w*:)\\]\\s*$";
        NSRegularExpression *classMethodRegularExpression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                                      options:0
                                                                                                        error:NULL];
        
        [classMethodRegularExpression enumerateMatchesInString:self.formatterName options:0 range:NSMakeRange(0, [self.formatterName length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            // Extract capture group information
            NSString *className = [self.formatterName substringWithRange:[result rangeAtIndex:1]];
            NSString *methodName = [self.formatterName substringWithRange:[result rangeAtIndex:2]];
            
            // Check
            Class class = NSClassFromString(className);
            if (! class) {
                self.errorDescription = [NSString stringWithFormat:@"The specified global formatter points to an invalid class '%@'", className];
                return;
            }
            
            SEL selector = NSSelectorFromString(methodName);
            if (! class_getClassMethod(class, selector)) {
                self.errorDescription = [NSString stringWithFormat:@"The specified global formatter method '%@' does not exist for the class '%@'", methodName, className];
                return;
            }
            
            formattingTarget = class;
            formattingSelector = selector;
        }];
        
        // No class method formatter found
        if (! formattingTarget) {
            // Perform instance method lookup
            formattingSelector = NSSelectorFromString(self.formatterName);
            if (! formattingSelector) {
                self.errorDescription = @"The formatter is not a valid method name";
                return NO;
            }
            
            // Look along the responder chain first (most specific)
            formattingTarget = [HLSViewBindingInformation bindingTargetForSelector:formattingSelector view:self.view];
            if (! formattingTarget) {
                // Look for an instance method on the object
                if ([self.object respondsToSelector:formattingSelector]) {
                    formattingTarget = self.object;
                }
                // Look for a class method on the object class itself (most generic)
                else if ([[self.object class] respondsToSelector:formattingSelector]) {
                    formattingTarget = [self.object class];
                }
                else {
                    self.errorDescription = @"The specified formatter is neither a global formatter, nor could be resolved along the responder chain";
                    return NO;
                }
            }
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id displayedValue = formattingTarget ? [formattingTarget performSelector:formattingSelector withObject:value] : value;
#pragma clang diagnostic pop
    
    // We cannot cache binding information if we cannot check the type of the value to be displayed for compatibility. Does not change
    // the status, a later check is required
    if (! displayedValue) {
        return NO;
    }
    
    if (! [self canDisplayValue:displayedValue]) {
        self.errorDescription = [NSString stringWithFormat:@"The %@ must return one of the following supported types: %@",
                                 formattingTarget ? @"formatter" : @"keypath",
                                 [self supportedBindingClassesString]];
        return NO;
    }
    
    // Cache the binding information we just verified
    self.formattingTarget = formattingTarget;
    self.formattingSelector = formattingSelector;
    self.errorDescription = nil;
    
    return YES;
}

#pragma mark Type checking

- (NSArray *)supportedBindingClasses
{
    Class viewClass = [self.view class];
    
    if ([viewClass respondsToSelector:@selector(supportedBindingClasses)]) {
        return [viewClass supportedBindingClasses];
    }
    else {
        return @[[NSString class]];
    }
}

- (NSString *)supportedBindingClassesString
{
    NSArray *supportedBindingClasses = [self supportedBindingClasses];
    NSMutableArray *classNames = [NSMutableArray array];
    for (Class supportedBindingClass in supportedBindingClasses) {
        [classNames addObject:NSStringFromClass(supportedBindingClass)];
    }
    return [classNames componentsJoinedByString:@", "];
}

- (BOOL)canDisplayValue:(id)value
{
    NSArray *supportedBindingClasses = [self supportedBindingClasses];
    for (Class supportedBindingClass in supportedBindingClasses) {
        if ([value isKindOfClass:supportedBindingClass]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark Context binding lookup

// Locate the first responder which implements the specified method. Stops at view controller boundaries
+ (id)bindingTargetForSelector:(SEL)selector view:(UIView *)view
{
    UIResponder *responder = view;
    while (responder) {
        // Instance formatter lookup first
        if ([responder respondsToSelector:selector]) {
            return responder;
        }
        
        // Class formatter lookup
        Class responderClass = [responder class];
        if ([responderClass respondsToSelector:selector]) {
            return responderClass;
        }
        
        // Does not get higher than the receiver parent view controller, which defines the binding context
        if ([responder isKindOfClass:[UIViewController class]]) {
            return nil;
        }
        
        responder = responder.nextResponder;
    }
    return nil;
}

+ (id)bindingTargetForKeyPath:(NSString *)keyPath view:(UIView *)view
{
    UIResponder *responder = view;
    while (responder) {
        @try {
            // Will throw an exception unless the keypath is valid
            [responder valueForKeyPath:keyPath];
            return responder;
        }
        @catch (NSException *exception) {
            // Does not get higher than the receiver parent view controller, which defines the binding context
            if ([responder isKindOfClass:[UIViewController class]]) {
                return nil;
            }
            
            responder = responder.nextResponder;
        }
    }
    return nil;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; object: %@; keyPath: %@; formatterName: %@; formattingTarget: %@>",
            [self class],
            self,
            self.object,
            self.keyPath,
            self.formatterName,
            self.formattingTarget];
}

@end
