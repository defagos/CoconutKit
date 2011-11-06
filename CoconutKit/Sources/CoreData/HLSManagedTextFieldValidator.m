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

@interface HLSManagedTextFieldValidator ()

@property (nonatomic, assign) UITextField *textField;
@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *fieldName;
@property (nonatomic, retain) NSFormatter *formatter;
@property (nonatomic, assign) id<HLSTextFieldValidationDelegate> validationDelegate;

@end

@implementation HLSManagedTextFieldValidator

#pragma mark Object creation and destruction

- (id)initWithTextField:(UITextField *)textField
          managedObject:(NSManagedObject *)managedObject 
              fieldName:(NSString *)fieldName 
              formatter:(NSFormatter *)formatter
     validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate
{
    if ((self = [super init])) {
        // Sanity check
        if (! managedObject) {
            HLSLoggerError(@"Missing managed object or field name");
            [self release];
            return nil;
        }
        
        // Property must exist for the managed object class
        NSPropertyDescription *propertyDescription = [[[managedObject entity] propertiesByName] objectForKey:fieldName];
        if (! propertyDescription) {
            HLSLoggerError(@"The property %@ does not exist for %@", fieldName, managedObject);
            [self release];
            return nil;
        }
        
        // Can only bind to attributes. Binding to other property kinds (relationships, fetched properties) does not
        // make sense
        if (! [propertyDescription isKindOfClass:[NSAttributeDescription class]]) {
            HLSLoggerError(@"The field %@ is not an attribute and cannot be bound", fieldName);
            [self release];
            return nil;
        }
        
        // Remember binding parameters
        self.textField = textField;
        self.managedObject = managedObject;
        self.fieldName = fieldName;
        self.formatter = formatter;
        self.validationDelegate = validationDelegate;
        
        // Initially sync text field with property value
        id value = [self.managedObject valueForKey:self.fieldName];
        if (value) {
            if (formatter) {
                NSString *stringValue = [formatter stringForObjectValue:value];
                if (! stringValue) {
                    HLSLoggerWarn(@"Formatting failed");
                }
                self.textField.text = stringValue;
            }
            else {
                self.textField.text = value;
            }            
        }
        else {
            self.textField.text = nil;
        }
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
    self.textField = nil;
    self.managedObject = nil;
    self.fieldName = nil;
    self.formatter = nil;
    self.delegate = nil;
    self.validationDelegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize textField = m_textField;

@synthesize managedObject = m_managedObject;

@synthesize fieldName = m_fieldName;

@synthesize formatter = m_formatter;

@synthesize delegate = m_delegate;

@synthesize validationDelegate = m_validationDelegate;

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.delegate textFieldShouldBeginEditing:textField];
    }
    else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    
    // Sync model object with field text
    id value = nil;
    if (self.formatter) {
        NSString *errorDescription = nil;
        if (! [self.formatter getObjectValue:&value forString:textField.text errorDescription:&errorDescription]) {
            HLSLoggerWarn(@"Formatting failed; reason: %@", errorDescription);
        }
    }
    else {
        value = textField.text;
    }
    [self.managedObject setValue:value forKey:self.fieldName];
    
    // Validate the field
    NSString *checkSelectorName = [NSString stringWithFormat:@"check%@%@:error:", [[self.fieldName substringToIndex:1] uppercaseString], 
                                   [self.fieldName substringFromIndex:1]];
    SEL checkSel = NSSelectorFromString(checkSelectorName);
    Method checkMethod = class_getInstanceMethod([self.managedObject class], checkSel);
    if (checkMethod) {
        NSError *error = nil;
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
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegate textFieldShouldClear:textField];
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
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
    return [NSString stringWithFormat:@"<%@: %p; textField: %@; managedObject: %@; fieldName: %@; formatter: %@; delegate: %@>", 
            [self class],
            self,
            self.textField,
            self.managedObject,
            self.fieldName,
            self.formatter,
            self.delegate];
}

@end
