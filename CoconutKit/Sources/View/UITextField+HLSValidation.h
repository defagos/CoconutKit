//
//  UITextField+HLSValidation.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSTextFieldValidationDelegate;

@interface UITextField (HLSValidation)

- (void)bindToManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName
                  formatter:(NSFormatter *)formatter
         validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate;

- (void)unbind;

- (NSManagedObject *)boundManagedObject;
- (NSString *)boundFieldName;
- (id<HLSTextFieldValidationDelegate>)validationDelegate;

/**
 * Validate each time the content of a text field changes
 */
- (BOOL)isCheckingOnChange;
- (void)setCheckingOnChange:(BOOL)checkingOnChange;

@end

@protocol HLSTextFieldValidationDelegate <NSObject>

@optional

- (void)textFieldDidPassValidation:(UITextField *)textField;
- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error;

@end

@interface UIViewController (HLSValidation)

// TODO: Document: This checks all fields and does not stop when an error is encountered
- (BOOL)checkAndSynchronize;

@end

@interface UIView (HLSValidation)

// TODO: See above
- (BOOL)checkAndSynchronize;

@end
