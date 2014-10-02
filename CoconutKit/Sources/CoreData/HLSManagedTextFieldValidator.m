//
//  HLSManagedTextFieldValidator.m
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "HLSManagedTextFieldValidator.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSManagedObject+HLSValidation.h"
#import "NSObject+HLSExtensions.h"

@interface HLSManagedTextFieldValidator ()

@property (nonatomic, weak) UITextField *textField;               // weak ref. Detector lifetime is managed by the text field
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, strong) NSString *fieldName;
@property (nonatomic, strong) NSFormatter *formatter;
@property (nonatomic, weak) id<HLSTextFieldValidationDelegate> validationDelegate;

@end

@implementation HLSManagedTextFieldValidator

#pragma mark Object creation and destruction

- (instancetype)initWithTextField:(UITextField *)textField
                    managedObject:(NSManagedObject *)managedObject
                        fieldName:(NSString *)fieldName
                        formatter:(NSFormatter *)formatter
               validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate
{
    if ((self = [super init])) {
        // Sanity check
        if (! managedObject || ! fieldName) {
            HLSLoggerError(@"Missing managed object or field name");
            return nil;
        }
        
        // The property must exist for the managed object class
        NSPropertyDescription *propertyDescription = [[[managedObject entity] propertiesByName] objectForKey:fieldName];
        if (! propertyDescription) {
            HLSLoggerError(@"The property %@ does not exist for %@", fieldName, managedObject);
            return nil;
        }
        
        // Can only bind to attributes. Binding to other property kinds (relationships, fetched properties) does not
        // make sense
        if (! [propertyDescription isKindOfClass:[NSAttributeDescription class]]) {
            HLSLoggerError(@"The field %@ is not an attribute and cannot be bound", fieldName);
            return nil;
        }
        
        // Binding parameters correct. Remember them
        self.textField = textField;
        self.managedObject = managedObject;
        self.fieldName = fieldName;
        self.formatter = formatter;
        self.validationDelegate = validationDelegate;
        
        // Perform initial synchronization of the text field with the model object field value
        [self synchronizeTextField];
        
        // Enable KVO to update the text field automatically when the model field value changes
        [managedObject addObserver:self
                        forKeyPath:fieldName
                           options:0
                           context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textField];
    }
    return self;
}

- (void)dealloc
{
    [self.managedObject removeObserver:self forKeyPath:self.fieldName];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Sync and check

// Does not return nil on failure, but a BOOL. nil could namely be a valid value
- (BOOL)getValue:(id *)pValue forString:(NSString *)string
{
    NSAssert(pValue, @"Missing value reference");
    
    // Do not attempt to format if no formatter has been attached. Output is a string as well
    if (! self.formatter) {
        *pValue = string;
        return YES;
    }
    
    // Nothing to format
    if ([string length] == 0) {
        *pValue = nil;
        return YES;
    }
    
    // Format the value
    // Remark: The formatting error descriptions are not explicit. No need to have a look at them 
    if (! [self.formatter getObjectValue:pValue forString:string errorDescription:NULL]) {
        HLSLoggerDebug(@"Formatting failed for field %@", self.fieldName);
        if ([self.validationDelegate respondsToSelector:@selector(textFieldDidFailFormatting:)]) {
            [self.validationDelegate textFieldDidFailFormatting:self.textField];
        }
        return NO;
    }
    
    HLSLoggerDebug(@"Formatting successful for field %@", self.fieldName);
    if ([self.validationDelegate respondsToSelector:@selector(textFieldDidPassFormatting:)]) {
        [self.validationDelegate textFieldDidPassFormatting:self.textField];
    }
    
    return YES;
}

- (void)setValue:(id)value
{
    [self.managedObject setValue:value forKey:self.fieldName];
}

// Check the given value. Returns YES iff valid
- (BOOL)checkValue:(id)value
{
    NSError *error = nil;
    if ([self.managedObject checkValue:value forKey:self.fieldName error:&error]) {
        if ([self.validationDelegate respondsToSelector:@selector(textFieldDidPassValidation:)]) {
            HLSLoggerDebug(@"Value %@ for field %@ is valid", value, self.fieldName);
            [self.validationDelegate textFieldDidPassValidation:self.textField];
        }
        return YES;
    }
    else {
        if ([self.validationDelegate respondsToSelector:@selector(textField:didFailValidationWithError:)]) {
            HLSLoggerDebug(@"Value %@ for field %@ is invalid", value, self.fieldName);
            [self.validationDelegate textField:self.textField didFailValidationWithError:error];
        }
        return NO;
    }
}

- (BOOL)checkDisplayedValue
{
    id value = nil;
    if (! [self getValue:&value forString:self.textField.text]) {
        return NO;
    }
    
    return [self checkValue:value];
}

// Synchronize the string displayed by the text field with the underlying model object field value
- (void)synchronizeTextField
{
    // By default, we display an empty string, not nil. As soon as a text field has been edited and is cleared, the empty
    // value is namely an empty string, never nil. The value which therefore makes sense for an empty text field is always
    // an empty string, not nil. Note that the placeholder text of a text field (if any) is displayed if the string is
    // empty or nil
    id value = [self.managedObject valueForKey:self.fieldName];
    NSString *text = @"";
    if (value) {
        // We do not display "0" for numbers equal to zero. This does not make much sense, an empty number text field
        // means 0, which allows the placeholder text to be displayed in such cases
        if ([value isKindOfClass:[NSNumber class]] && [value isEqualToNumber:@0]) {
            text = @"";
        }
        else if (self.formatter) {
            NSString *formattedValue = [self.formatter stringForObjectValue:value];
            if (formattedValue) {
                text = formattedValue;
            }
            else {
                text = @"";
            }
        }
        else {
            text = value;
        }            
    }
    
    self.textField.text = text;
}

#pragma mark Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Every time the value of the model object field changes, we want to trigger validation to update the text field
    // accordingly
    id newValue = [object valueForKey:keyPath];
    [self checkValue:newValue];
    
    // The value might have been changed programmatically. Be sure to update the text field text in all cases to take
    // this fact into account
    [self synchronizeTextField];
}

#pragma mark Notification callbacks

- (void)textFieldDidChange:(NSNotification *)notification
{
    // Check when typing?
    if (self.checkingOnChange) {
        id value = nil;
        if ([self getValue:&value forString:self.textField.text]) {
            [self checkValue:value];
        }
        
        // The model is not updated here. It will be when input mode is exited
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; textField: %@; managedObject: %@; fieldName: %@; formatter: %@>", 
            [self class],
            self,
            self.textField,
            self.managedObject,
            self.fieldName,
            self.formatter];
}

@end
