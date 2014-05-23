//
//  UITextField+HLSValidation.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.10.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "UITextField+HLSValidation.h"

#import "HLSManagedTextFieldValidator.h"
#import "HLSRuntime.h"

#import <objc/runtime.h>

// Associated object keys
static void *s_validatorKey = &s_validatorKey;

// Original implementation of the methods we swizzle
void (*UITextField__setText_Imp)(id, SEL, id) = NULL;                       // external linkage
static void (*UITextField__setAttributedText_Imp)(id, SEL, id) = NULL;      // external linkage

// Swizzled method implementations
static void swizzled_UITextField__setText_Imp(UITextField *self, SEL _cmd, NSString *text);
static void swizzled_UITextField__setAttributedText_Imp(UITextField *self, SEL _cmd, NSAttributedString *attributedText);

// Extern declarations
extern BOOL injectedManagedObjectValidation(void);

#pragma mark -
#pragma mark HLSValidation UITextField category implementation

@implementation UITextField (HLSValidation)

#pragma mark Class methods

+ (void)load
{
    UITextField__setText_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                @selector(setText:),
                                                                                (IMP)swizzled_UITextField__setText_Imp);
    UITextField__setAttributedText_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                @selector(setAttributedText:),
                                                                                (IMP)swizzled_UITextField__setAttributedText_Imp);
}

#pragma mark Binding to managed object fields

- (void)bindToManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName 
                  formatter:(NSFormatter *)formatter
         validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
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
    
    objc_setAssociatedObject(self, s_validatorKey, validator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

- (void)unbind
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
    // If not bound to a validator, nothing to do
    if (! objc_getAssociatedObject(self, s_validatorKey)) {
        return;
    }
    
    // Remove the validator
    objc_setAssociatedObject(self, s_validatorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

#pragma mark Accessors and mutators

- (BOOL)isCheckingOnChange
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    if (! validator) {
        return NO;
    }
    
    return validator.checkingOnChange;
}

- (void)setCheckingOnChange:(BOOL)checkingOnChange
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    if (! validator) {
        return;
    }
    
    validator.checkingOnChange = checkingOnChange;
}

@end

#pragma mark -
#pragma mark HLSValidation UIView category implementation

@implementation UIView (HLSValidation)

- (BOOL)checkTextFields
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
    // Check self first (if bound to a validator)
    BOOL valid = YES;
    if ([self isKindOfClass:[UITextField class]]) {
        HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
        if (validator && ! [validator checkDisplayedValue]) {
            valid = NO;
        }
    }
    
    // Check subviews recursively
    for (UIView *subview in self.subviews) {
        if (! [subview checkTextFields]) {
            valid = NO;
        }
    }
    
    return valid;
}

@end

#pragma mark -
#pragma mark HLSValidation UIViewController category implementation

@implementation UIViewController (HLSValidation)

- (BOOL)checkTextFields
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
    if (! [self isViewLoaded]) {
        return NO;
    }
    
    return [self.view checkTextFields];
}

@end

#pragma mark -
#pragma mark Swizzled method implementations

// Swizzled so that changes made to the text field (either programmatically or interactively) are trapped. We need to swizzle setText: prior
// to iOS 6 and setAttributedText: on iOS 7 (respectively called by _endedEditing when exiting edit mode, on iOS 6 and iOS 7 respectively)

// TODO: Drop setText: swizzle when CoconutKit supports iOS 7 and above only
static void swizzled_UITextField__setText_Imp(UITextField *self, SEL _cmd, NSString *text)
{
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    if (validator) {
        id value = nil;
        [validator getValue:&value forString:text];
        [validator setValue:value];
    }
    else {
        (*UITextField__setText_Imp)(self, _cmd, text);
    }    
}

static void swizzled_UITextField__setAttributedText_Imp(UITextField *self, SEL _cmd, NSAttributedString *attributedText)
{
    HLSManagedTextFieldValidator *validator = objc_getAssociatedObject(self, s_validatorKey);
    if (validator) {
        id value = nil;
        [validator getValue:&value forString:[attributedText string]];
        [validator setValue:value];
    }
    else {
        (*UITextField__setAttributedText_Imp)(self, _cmd, attributedText);
    }
}
