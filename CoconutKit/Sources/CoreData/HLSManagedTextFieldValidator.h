//
//  HLSManagedTextFieldValidator.h
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "UITextField+HLSValidation.h"

/**
 * Private class for implementation purposes. Synchronizes the text field value with a managed field object and performs 
 * automatic validation when appropriate
 *
 * Designated initializer: -initWithTextField:managedObject:fieldName:formatter:validationDelegate:
 */
@interface HLSManagedTextFieldValidator : NSObject

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
 * If set to YES, validation is also called during input.
 * Default value is NO
 */
@property (nonatomic, assign, getter=isCheckingOnChange) BOOL checkingOnChange;

/**
 * Formats string and returns it by reference in pValue (must not be NULL). Returns YES iff successful
 */
- (BOOL)getValue:(id *)pValue forString:(NSString *)string;

/**
 * Set the managed object field using the value provided as parameter
 */
- (void)setValue:(id)value;

/**
 * Check the value currently displayed by the text field. Returns YES iff valid
 */
- (BOOL)checkDisplayedValue;

@end
