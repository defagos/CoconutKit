//
//  HLSViewBindingInformation.m
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSViewBindingInformation.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIView+HLSViewBindingFriend.h"

#import <objc/runtime.h>

@interface HLSViewBindingInformation ()

@property (nonatomic, weak) id object;                      // weak ref
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, strong) NSString *formatterName;
@property (nonatomic, weak) UIView *view;                   // weak ref

@property (nonatomic, weak) id formattingTarget;            // weak ref
@property (nonatomic, assign) SEL formattingSelector;

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
        
        if (object) {
            // Check that the keypath is valid
            @try {
                [object valueForKeyPath:keyPath];
            }
            @catch (NSException *exception) {
                HLSLoggerError(@"Invalid keypath %@ for object %@", keyPath, object);
                return nil;
            }
        }
        else {
            object = [HLSViewBindingInformation bindingTargetForKeyPath:keyPath view:view];
            if (! object) {
                HLSLoggerError(@"No responder was found for keypath %@", keyPath);
                return nil;
            }
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
    if (! [self verifyBindingInformation]) {
        return nil;
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

// Return YES iff the binding information could be verified (keypath is valid, and any required formatting
// method could be located). Having the method return NO either means the binding information is incorrect,
// or that it could not be verified yet (because the keypath is valid but returns nil). Once binding
// information has been verified once it is stored for later efficient access
- (BOOL)verifyBindingInformation
{
    // Already verified and cached. Nothing to do
    if (self.verified) {
        return YES;
    }
    
    // No need to check for exceptions here, this has been done by the initializer
    id value = [self.object valueForKeyPath:self.keyPath];
    
    // The keypath is valid, but we cannot check its type (to guess if formatting is needed)
    if (! value) {
        return NO;
    }
    
    // No formatting required. We are done, the binding is correct
    if ([value isKindOfClass:[NSString class]]) {
        self.verified = YES;
        return YES;
    }
    
    // Formatting required. Check that a formatter is available
    if (! self.formatterName) {
        HLSLoggerError(@"The value returned by the binding path %@ is of class %@, you must provide a "
                       "formatterName user-defined runtime attribute to format it as an NSString", self.keyPath, [value className]);
        return NO;
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
            HLSLoggerError(@"Invalid class name");
            return;
        }
        
        SEL selector = NSSelectorFromString(methodName);
        if (! class_getClassMethod(class, selector)) {
            HLSLoggerError(@"Invalid method name");
            return;
        }
        
        formattingTarget = class;
        formattingSelector = selector;
    }];
    
    if (! formattingTarget) {
        // Perform instance method lookup
        formattingSelector = NSSelectorFromString(self.formatterName);
        if (! formattingSelector) {
            HLSLoggerError(@"Invalid formatter name %@", self.formatterName);
            return NO;
        }
        
        // Look along the responder chain first (most specific)
        formattingTarget = [HLSViewBindingInformation bindingTargetForSelector:formattingSelector view:self.view];
        if (! formattingTarget) {
            // Look on the object itself (most generic)
            if (! [self.object respondsToSelector:formattingSelector]) {
                HLSLoggerError(@"No formatter method %@ is available on the view / view controller hiearchy, nor on the "
                               "object class %@ itself", self.formatterName, [self.object className]);
                return NO;
            }
            
            formattingTarget = self.object;
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id formattedValue = [formattingTarget performSelector:formattingSelector withObject:value];
#pragma clang diagnostic pop
    if (! [formattedValue isKindOfClass:[NSString class]]) {
        HLSLoggerError(@"The formatter method %@ must return an NSString", self.formatterName);
        return NO;
    }
    
    // Cache the binding information we just verified
    self.formattingTarget = formattingTarget;
    self.formattingSelector = formattingSelector;
    self.verified = YES;
    return YES;
}

#pragma mark Context binding lookup

// Locate the first responder which implements the specified method
+ (id)bindingTargetForSelector:(SEL)selector view:(UIView *)view
{
    UIResponder *responder = view;
    while (responder) {
        if ([responder respondsToSelector:selector]) {
            return responder;
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

@end
