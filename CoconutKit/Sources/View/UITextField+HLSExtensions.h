//
//  UITextField+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSTextFieldValidationDelegate;

@interface UITextField (HLSExtensions)

- (void)bindToManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName
                  formatter:(NSFormatter *)formatter
         validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate;

- (void)unbind;

- (BOOL)check;

- (NSManagedObject *)boundManagedObject;
- (NSString *)boundFieldName;
- (id<HLSTextFieldValidationDelegate>)validationDelegate;

@end

@protocol HLSTextFieldValidationDelegate <NSObject>

@optional

- (void)textFieldDidPassValidation:(UITextField *)textField;
- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error;

@end

@interface UIViewController (HLSTextFieldValidation)

- (BOOL)checkTextFields:(NSError **)pError;

@end

@interface UIView (HLSTextFieldValidation)

- (BOOL)checkTextFields:(NSError **)pError;

@end
