//
//  UITextField+HLSValidation.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSTextFieldValidationDelegate;

/**
 * This class extension allows UITextField objects to be bound to Core Data model object fields, provided HLSValidation 
 * has been enabled on NSManagedObject (for more information, please refer to NSManagedObject+HLSValidation.h first).
 *
 * Binding eliminates the need to write code to synchronize a model object field and the text field used to display
 * and edit its value. Moreover, if a -check<fieldName>:error: method has been defined for the managed object field, 
 * it will automatically be called, either when exiting input mode or when the field value changes (this can be enabled
 * using a dedicated setting).
 *
 * When a text field gets bound, its value is set to the current value of the model object field. If the model
 * object field value changes after it has been bound, the text field gets updated (and validated) accordingly.
 * Conversely, when a text field has been edited (i.e. when exiting input mode), the model object field value
 * is automatically updated. An optional NSFormatter can be attached to the field to automatically format or parse
 * the value displayed by the text field. A validation delegate, optional as well, receives validation events.
 *
 * Otherwise, a bound text field behaves exactly as a normal text field. In particular, some delegate must implement
 * UITextFieldDelegate protocol methods to dismiss the keyboard when appropriate.
 *
 * Categories on UIView and UIViewController are also provided. These can be used to trigger validation for all
 * text fields within a view hierarchy (or view controller's view hierarchy). This is especially useful when 
 * implementing an OK button validating a whole form.
 *
 * To use any of the methods in the HLSValidation text field category, HLSValidation must be enabled on NSManagedObject
 * first. This is achieved by calling the HLSEnableNSManagedObjectValidation macro at global scope.
 */
@interface UITextField (HLSValidation)

/**
 * Bind the text field to a specific field of a managed object. A formatter and a validation delegate can be provided
 */
- (void)bindToManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName
                  formatter:(NSFormatter *)formatter
         validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate;

/**
 * Remove any binding which might have been defined for the text field
 */
- (void)unbind;

/**
 * If checking on change is enabled (it is disabled by default), then validation is performed as the user changes the
 * text field content. Otherwise validation is only performed when exiting edit mode for this field, or when it loses 
 * focus
 */
- (BOOL)isCheckingOnChange;
- (void)setCheckingOnChange:(BOOL)checkingOnChange;

@end

/**
 * Protocol implemented by validation delegates
 */
@protocol HLSTextFieldValidationDelegate <NSObject>

@optional

/**
 * Called when formatting has been successful
 */
- (void)textFieldDidPassFormatting:(UITextField *)textField;

/**
 * Called when formatting failed
 */
- (void)textFieldDidFailFormatting:(UITextField *)textField;

/**
 * Called when validation has been successful
 */
- (void)textFieldDidPassValidation:(UITextField *)textField;

/**
 * Called when validation failed. The error which is received can be used to display further information to the user
 */
- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error;

@end

@interface UIView (HLSValidation)

/**
 * Check all text fields in the receiver view hierarchy. Returns YES iff all of them are valid
 */
- (BOOL)checkTextFields;

@end

@interface UIViewController (HLSValidation)

/**
 * Same as -[UIView checkTextFields], but applied to a view controller's view
 */
- (BOOL)checkTextFields;

@end
