//
//  UITextField+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "UITextField+HLSExtensions.h"

#import "HLSLogger.h"
#import "HLSManagedTextFieldValidator.h"
#import "HLSRuntime.h"

#import <objc/runtime.h>

// Associated object keys
static void *s_validatorKey = &s_validatorKey;

// Original implementation of the methods we swizzle
static id<UITextFieldDelegate> (*s_UITextField__delegate_Imp)(id, SEL) = NULL;
static void (*s_UITextField__setDelegate_Imp)(id, SEL, id) = NULL;

// Extern declarations
extern BOOL injectedManagedObjectValidation(void);

@interface UITextField (HLSExtensionsPrivate)

- (id<UITextFieldDelegate>)swizzledDelegate;
- (void)swizzledSetDelegate:(id<UITextFieldDelegate>) delegate;

@end

@implementation UITextField (HLSExtensions)

#pragma mark Binding to managed object fields

- (void)bindToManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName 
                  formatter:(NSFormatter *)formatter
         validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate
{
    // Ensure that injection has been enabled
    if (! injectedManagedObjectValidation()) {
        HLSLoggerError(@"Text field cannot be bound, call HLSEnableNSManagedObjectValidation() first");
        return;
    }
    
    // First unbind any bound field
    [self unbind];
    
    // No object to bind. Nothing to do
    if (! managedObject) {
        return;
    }
    
    // Bind to a validator object, with the current text field delegate as validator delegate
    HLSManagedTextFieldValidator *validator = [[[HLSManagedTextFieldValidator alloc] initWithTextField:self 
                                                                                         managedObject:managedObject
                                                                                             fieldName:fieldName 
                                                                                             formatter:formatter
                                                                                    validationDelegate:validationDelegate] 
                                               autorelease];
    if (! validator) {
        return;
    }
    
    validator.delegate = (*s_UITextField__delegate_Imp)(self, @selector(delegate));
    objc_setAssociatedObject(self, s_validatorKey, validator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Set the validator as text field delegate to catch events and perform validation. We need an intermediate object 
    // because trying to set self as delegate does not work for a UITextField
    (*s_UITextField__setDelegate_Imp)(self, @selector(setDelegate:), validator);
}

- (void)unbind
{
    // If not bound to a validator, nothing to do
    if (! objc_getAssociatedObject(self, s_validatorKey)) {
        return;
    }
    
    // Restore the original delegate
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    (*s_UITextField__setDelegate_Imp)(self, @selector(setDelegate:), validator.delegate);
    
    // Remove the validator
    objc_setAssociatedObject(self, s_validatorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

#pragma mark Accessors and mutators

- (NSManagedObject *)boundManagedObject
{
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    return validator.managedObject;
}

- (NSString *)boundFieldName
{
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    return validator.fieldName;
}

- (id<HLSTextFieldValidationDelegate>)validationDelegate
{
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    return validator.validationDelegate;    
}

@end

@implementation UITextField (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UITextField__delegate_Imp = (id<UITextFieldDelegate> (*)(id, SEL))HLSSwizzleSelector(self, @selector(delegate), @selector(swizzledDelegate));
    s_UITextField__setDelegate_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(setDelegate:), @selector(swizzledSetDelegate:));
}

#pragma mark Swizzled method implementations

- (id<UITextFieldDelegate>)swizzledDelegate
{
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    if (validator) {
        return validator.delegate;
    }
    else {
        return (*s_UITextField__delegate_Imp)(self, @selector(delegate));
    }
}

- (void)swizzledSetDelegate:(id<UITextFieldDelegate>)delegate
{
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    if (validator) {
        validator.delegate = delegate;
    }
    else {
        (*s_UITextField__setDelegate_Imp)(self, @selector(setDelegate:), delegate);
    }
}

@end
