//
//  HLSManagedTextFieldValidator.h
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "UITextField+HLSValidation.h"

/**
 * A UITextField cannot be its own delegate (this leads to infinite recursion when entering edit mode of a text field
 * which is its own delegate). In general, it is probably better to avoid having an object being its own delegate. If
 * we want to trap text field delegate events to perform additional tasks (here validation), we therefore need an 
 * additional object as delegate, and having the real text field delegate as its delegate. This is just the purpose 
 * of this (private) HLSManagedTextFieldValidator class.
 *
 * Designated initializer: initWithTextField:managedObject:fieldName:formatter:validationDelegate:
 */
@interface HLSManagedTextFieldValidator : NSObject <UITextFieldDelegate> {
@private
    UITextField *m_textField;
    NSManagedObject *m_managedObject;
    NSString *m_fieldName;
    NSFormatter *m_formatter;
    id<UITextFieldDelegate> m_delegate;
    id<HLSTextFieldValidationDelegate> m_validationDelegate;
    BOOL m_checkingOnChange;
}

/**
 * Initialize with a managed object and the field we want to validate, as well as a delegate which must receive
 * validation events. An optional formatter can be provided if needed (e.g. for date or numeric fields)
 */
- (id)initWithTextField:(UITextField *)textField
          managedObject:(NSManagedObject *)managedObject 
              fieldName:(NSString *)fieldName 
              formatter:(NSFormatter *)formatter
     validationDelegate:(id<HLSTextFieldValidationDelegate>)validationDelegate;

/**
 * Validator properties set at creation time
 */
@property (nonatomic, readonly, assign) UITextField *textField;
@property (nonatomic, readonly, retain) NSManagedObject *managedObject;
@property (nonatomic, readonly, retain) NSString *fieldName;
@property (nonatomic, readonly, retain) NSFormatter *formatter;
@property (nonatomic, readonly, assign) id<HLSTextFieldValidationDelegate> validationDelegate;

/**
 * If set to YES, validation is also called during input.
 * Default value is NO
 */
@property (nonatomic, assign, getter=isCheckingOnChange) BOOL checkingOnChange;

- (BOOL)checkDisplayedValue;
- (void)synchronizeWithDisplayedValue;

/**
 * The delegate to forward UITextFieldDelegate events to after the validator has performed its work
 */
@property (nonatomic, assign) id<UITextFieldDelegate> delegate;

@end
