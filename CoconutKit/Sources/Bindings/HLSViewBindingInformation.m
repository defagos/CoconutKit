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

#import <objc/runtime.h>

typedef enum {
    HLSViewBindingInformationStatusEnumBegin = 0,
    HLSViewBindingInformationStatusUnchecked = HLSViewBindingInformationStatusEnumBegin,
    HLSViewBindingInformationStatusValid,
    HLSViewBindingInformationStatusInvalid,
    HLSViewBindingInformationStatusEnumEnd,
    HLSViewBindingInformationStatusEnumSize = HLSViewBindingInformationStatusEnumEnd - HLSViewBindingInformationStatusEnumBegin
} HLSViewBindingInformationStatus;

@interface HLSViewBindingInformation ()

@property (nonatomic, weak) id object;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, strong) NSString *formatterName;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, weak) id formattingTarget;
@property (nonatomic, assign) SEL formattingSelector;

@property (nonatomic, assign) HLSViewBindingInformationStatus status;

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

- (NSString *)text
{
    // Lazily check and fill binding information
    if (self.status == HLSViewBindingInformationStatusUnchecked) {
        self.status = [self verifyBindingInformation];
    }
    
    if (self.status == HLSViewBindingInformationStatusInvalid) {
        return @"NaB";
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

// Return 'valid' if the binding information can be verified (keypath is valid, and any required formatting
// method could be located). If the information is valid but cannot not be fully checked (the keypath is
// correct, but returns nil), returns 'unchecked'. Otherwise returns 'invalid'
- (HLSViewBindingInformationStatus)verifyBindingInformation
{
    if ([self.object isEqual:HLSViewBindingInformationEmptyObject]) {
        self.object = nil;
        return HLSViewBindingInformationStatusValid;
    }
    // An object has been provided. Check that the keypath is valid for it
    else if (self.object) {
        @try {
            [self.object valueForKeyPath:self.keyPath];
        }
        @catch (NSException *exception) {
            HLSLoggerError(@"Invalid keypath '%@' for object %@", self.keyPath, self.object);
            return HLSViewBindingInformationStatusInvalid;
        }
    }
    // No object provided. Walk along the responder chain to find a responder matching the keypath
    else {
        self.object = [HLSViewBindingInformation bindingTargetForKeyPath:self.keyPath view:self.view];
        if (! self.object) {
            HLSLoggerError(@"No responder was found for keypath '%@'", self.keyPath);
            return HLSViewBindingInformationStatusInvalid;
        }
    }
    
    // No need to check for exceptions here, the keypath is here guaranteed to be valid the object
    id value = [self.object valueForKeyPath:self.keyPath];
    
    // The keypath is valid, but we cannot check its type (to guess if formatting is needed) since there is no
    // value. Does not change the status, another check is required
    if (! value) {
        return HLSViewBindingInformationStatusUnchecked;
    }
    
    // No formatting required. We are done, the binding is correct
    if ([value isKindOfClass:[NSString class]]) {
        return HLSViewBindingInformationStatusValid;
    }
    
    // Formatting required. Check that a formatter is available
    if (! self.formatterName) {
        HLSLoggerError(@"The value returned by the binding keypath '%@' is of class %@, you must provide a formatterName "
                       "user-defined runtime attribute to format it as an NSString", self.keyPath, [value className]);
        return HLSViewBindingInformationStatusInvalid;
    }
    
    __block id formattingTarget = nil;
    __block SEL formattingSelector = NULL;
    
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
            HLSLoggerError(@"Invalid formatter class name %@ for keypath '%@'", className, self.keyPath);
            return;
        }
        
        SEL selector = NSSelectorFromString(methodName);
        if (! class_getClassMethod(class, selector)) {
            HLSLoggerError(@"Invalid formatter method name '%@' for keypath '%@'", methodName, self.keyPath);
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
            HLSLoggerError(@"Invalid formatter name '%@' for keypath '%@'", self.formatterName, self.keyPath);
            return HLSViewBindingInformationStatusInvalid;
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
                HLSLoggerError(@"No formatter method '%@' could be found for keypath '%@'", self.formatterName, self.keyPath);
                return HLSViewBindingInformationStatusInvalid;
            }
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id formattedValue = [formattingTarget performSelector:formattingSelector withObject:value];
#pragma clang diagnostic pop
    if (! [formattedValue isKindOfClass:[NSString class]]) {
        HLSLoggerError(@"The formatter method '%@' associated with the keypath '%@' must return an NSString", self.formatterName, self.keyPath);
        return HLSViewBindingInformationStatusInvalid;
    }
    
    // Cache the binding information we just verified
    self.formattingTarget = formattingTarget;
    self.formattingSelector = formattingSelector;
    
    return HLSViewBindingInformationStatusValid;
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
