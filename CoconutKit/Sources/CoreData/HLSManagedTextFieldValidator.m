//
//  HLSManagedTextFieldValidator.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSManagedTextFieldValidator.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import <objc/runtime.h>

// TODO: Sync value. Provide with callback to let perform customization in both
//       directions value -> field and field -> value, typically formatting / parsing

@interface HLSManagedTextFieldValidator ()

@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *fieldName;
@property (nonatomic, assign) id<HLSTextFieldValidationDelegate> validationDelegate;

@end

@implementation HLSManagedTextFieldValidator

#pragma mark Object creation and destruction

- (id)initWithFieldName:(NSString *)fieldName 
          managedObject:(NSManagedObject *)managedObject 
     validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate;
{
    if ((self = [super init])) {
        if (! fieldName /* || property does not exist for managed object class */) {
            HLSLoggerError(@"The property %@ does not exist for the object %@", fieldName, managedObject);
            [self release];
            return nil;
        }
        
        self.managedObject = managedObject;
        self.fieldName = fieldName;
        self.validationDelegate = validationDelegate;
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
    // TODO: Should sync model object with field
    
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
