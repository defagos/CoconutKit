//
//  HLSManagedTextFieldValidator.m
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSManagedTextFieldValidator.h"

#import "HLSAssert.h"
#import "HLSError.h"
#import "HLSLogger.h"
#import "NSManagedObject+HLSValidation.h"
#import "NSObject+HLSExtensions.h"

// This implementation has been swizzled in UITextField+HLSValidation.m
extern void (*UITextField__setText_Imp)(id, SEL, id);

@interface HLSManagedTextFieldValidator ()

@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *fieldName;
@property (nonatomic, retain) NSFormatter *formatter;
@property (nonatomic, assign) id<HLSTextFieldValidationDelegate> validationDelegate;

- (BOOL)checkValue:(id)value;
- (void)synchronizeTextField;

@end

@implementation HLSManagedTextFieldValidator

#pragma mark Object creation and destruction

- (id)initWithTextField:(UITextField *)textField
          managedObject:(NSManagedObject *)managedObject 
              fieldName:(NSString *)fieldName 
              formatter:(NSFormatter *)formatter
     validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate
{
    if ((self = [super initWithTextField:textField])) {
        // Sanity check
        if (! managedObject || ! fieldName) {
            HLSLoggerError(@"Missing managed object or field name");
            [self release];
            return nil;
        }
        
        // The property must exist for the managed object class
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
        
        // Binding parameters correct. Remember them
        self.managedObject = managedObject;
        self.fieldName = fieldName;
        self.formatter = formatter;
        self.validationDelegate = validationDelegate;
        
        // Perform initial synchronization of the text field with the model object field value
        [self synchronizeTextField];
        
        // Enable KVO to update the text field automatically when the model field value changes
        [self.managedObject addObserver:self
                             forKeyPath:self.fieldName 
                                options:0 
                                context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self.managedObject removeObserver:self forKeyPath:self.fieldName];
    
    self.managedObject = nil;
    self.fieldName = nil;
    self.formatter = nil;
    self.validationDelegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize managedObject = m_managedObject;

@synthesize fieldName = m_fieldName;

@synthesize formatter = m_formatter;

@synthesize validationDelegate = m_validationDelegate;

@synthesize checkingOnChange = m_checkingOnChange;

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (! [super textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
        return NO;
    }
    
    // Check when typing?
    if (self.checkingOnChange) {
        id value = nil;
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([self getValue:&value forString:updatedText]) {
            [self checkValue:value];
        }
        
        // The model is not updated here. It will be when input mode is exited
    }
    
    return YES;
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
    // an empty string, not nil
    id value = [self.managedObject valueForKey:self.fieldName];
    NSString *text = @"";
    if (value) {
        if (self.formatter) {
            NSString *formattedValue = [self.formatter stringForObjectValue:value];
            if (formattedValue) {
                text = formattedValue;
            }
        }
        else {
            text = value;
        }            
    }
    
    // Set the value. Use the original setter to avoid triggering validation again (which is why the setter has
    // been swizzled)
    (*UITextField__setText_Imp)(self.textField, @selector(setText:), text);
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
