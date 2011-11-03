//
//  HLSManagedTextFieldValidator.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSManagedTextFieldValidator.h"

#import "HLSAssert.h"
#import <objc/runtime.h>

@interface HLSManagedTextFieldValidator ()

@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *fieldName;

@end

@implementation HLSManagedTextFieldValidator

#pragma mark Object creation and destruction

- (id)initWithFieldName:(NSString *)fieldName ofManagedObject:(NSManagedObject *)managedObject
{
    if ((self = [super init])) {
        self.managedObject = managedObject;
        self.fieldName = fieldName;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.managedObject = nil;
    self.fieldName = nil;
    self.delegate = nil;
    self.validationDelegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize managedObject = m_managedObject;

@synthesize fieldName = m_fieldName;

@synthesize delegate = m_delegate;

@synthesize validationDelegate = m_validationDelegate;

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.delegate textFieldShouldBeginEditing:textField];
    }
    else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    // TODO: Should also probably sync
    
    // Validate the field
    NSString *checkSelectorName = [NSString stringWithFormat:@"check%@%@:error:", [[self.fieldName substringToIndex:1] uppercaseString], 
                                   [self.fieldName substringFromIndex:1]];
    SEL checkSel = NSSelectorFromString(checkSelectorName);
    Method checkMethod = class_getInstanceMethod([self.managedObject class], checkSel);
    if (checkMethod) {
        NSError *error = nil;
        
        // TODO: Extract value properly and automatically based on its type
        NSString *value = textField.text;
        
        BOOL (*checkImp)(id, SEL, id, NSError **) = (BOOL (*)(id, SEL, id, NSError **))method_getImplementation(checkMethod);
        if ((*checkImp)(self, checkSel, value, &error)) {
            if ([self.validationDelegate respondsToSelector:@selector(textFieldDidPassValidation:)]) {
                [self.validationDelegate textFieldDidPassValidation:textField];
            }
        }
        else {
            if ([self.validationDelegate respondsToSelector:@selector(textField:didFailValidationWithError:)]) {
                [self.validationDelegate textField:textField didFailValidationWithError:error];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.delegate textFieldShouldEndEditing:textField];
    }
    else {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegate textFieldShouldClear:textField];
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.delegate textFieldShouldReturn:textField];
    }
    else {
        return YES;
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; managedObject: %@; fieldName: %@; delegate: %@>", 
            [self class],
            self,
            self.managedObject,
            self.fieldName,
            self.delegate];
}

@end
