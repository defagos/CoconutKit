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

- (void)bindToField:(NSString *)field ofManagedObject:(NSManagedObject *)managedObject;
- (void)unbind;

- (NSManagedObject *)boundManagedObject;
- (NSString *)boundTextField;

/**
 * The delegate to which validation events must be forwarded. This delegate can only be defined after a text field
 * has been bound to a model object
 */
@property (nonatomic, assign) id<HLSTextFieldValidationDelegate> validationDelegate;

@end

@protocol HLSTextFieldValidationDelegate <NSObject>

@optional
- (void)textFieldDidPassValidation:(UITextField *)textField;
- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error;

@end
