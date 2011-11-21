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

static NSString * const kManagedTextFieldFormattingError = @"kManagedTextFieldFormattingError";

@interface HLSManagedTextFieldValidator ()

@property (nonatomic, assign) UITextField *textField;
@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *fieldName;
@property (nonatomic, retain) NSFormatter *formatter;
@property (nonatomic, assign) id<HLSTextFieldValidationDelegate> validationDelegate;

- (BOOL)getValue:(id *)pValue forString:(NSString *)string;
- (BOOL)checkValue:(id)value;

@end

@implementation HLSManagedTextFieldValidator

#pragma mark Class methods

+ (void)load
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [HLSError registerDefaultCode:NSManagedObjectValidationError
                           domain:@"ch.hortis.CoconutKit" 
             localizedDescription:NSLocalizedStringFromTable(@"Formatting error", @"CoconutKit_Localizable", @"Formatting error")
                    forIdentifier:kManagedTextFieldFormattingError];
    
    [pool drain];
}

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

@synthesize checkingOnChange = m_checkingOnChange;

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
    
    // Forward to text field delegate first
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        if (! [self.delegate textFieldShouldEndEditing:textField]) {
            return NO;
        }
    }
    
    // Only check the value if it can be properly formatted
    id value = nil;
    if ([self getValue:&value forString:textField.text]) {
        // If valid, then sync model object
        if ([self checkValue:value]) {
            [self.managedObject setValue:value forKey:self.fieldName];
        }
    }
    
    // In all cases end editing, even if the value is invalid. In this case, the model object won't be updated
    return YES;
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
        if (! [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            return NO;
        }
    }
    
    if (self.checkingOnChange) {
        id value = nil;
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([self getValue:&value forString:updatedText]) {
            // Check, but do not sync. Sync is always done when exiting edit mode
            [self checkValue:value];
        }
    }
    
    return YES;
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

#pragma mark Sync and check

// Does not return nil on failure, but a BOOL. nil could namely be a valid value, and if formatting fails we want
// to return an error to the user in all cases
- (BOOL)getValue:(id *)pValue forString:(NSString *)string
{
    NSAssert(pValue, @"Missing value reference");
    
    if (self.formatter) {
        // The error descriptions are not explicit. No need to have a look at them 
        if (! [self.formatter getObjectValue:pValue forString:string errorDescription:NULL]) {
            HLSError *error = [HLSError errorFromIdentifier:kManagedTextFieldFormattingError];
            if ([self.validationDelegate respondsToSelector:@selector(textField:didFailValidationWithError:)]) {
                [self.validationDelegate textField:self.textField didFailValidationWithError:error];
            }
            
            return NO;
        }
    }
    else {
        *pValue = string;
    }
    
    return YES;
}

- (BOOL)checkValue:(id)value
{
    NSError *error = nil;
    if ([self.managedObject checkValue:value forKey:self.fieldName error:&error]) {
        if ([self.validationDelegate respondsToSelector:@selector(textFieldDidPassValidation:)]) {
            [self.validationDelegate textFieldDidPassValidation:self.textField];
        }
        return YES;
    }
    else {
        if ([self.validationDelegate respondsToSelector:@selector(textField:didFailValidationWithError:)]) {
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

- (void)synchronizeWithDisplayedValue
{
    id value = nil;
    if (! [self getValue:&value forString:self.textField.text]) {
        HLSLoggerError(@"The value could not be formatted and therefore not synchronized");
        return;
    }
    
    [self.managedObject setValue:value forKey:self.fieldName];
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
