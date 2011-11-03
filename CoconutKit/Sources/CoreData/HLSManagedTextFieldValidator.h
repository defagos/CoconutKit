//
//  HLSManagedTextFieldValidator.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "UITextField+HLSExtensions.h"

/**
 * A UITextField cannot be its own delegate (this leads to infinite recursion when entering edit mode of a text field
 * which is its own delegate). In general, it is probably better to avoid having an object being its own delegate. If
 * we want to trap text field delegate events to do additional validation, we therefore need an additional object
 * as delegate, and having the real text field delegate as its delegate. This is just the purpose of the (private)
 * HLSManagedTextFieldValidator class.
 *
 * Designated initializer: initWithFieldName:ofManagedObject:
 */
@interface HLSManagedTextFieldValidator : NSObject <UITextFieldDelegate> {
@private
    NSManagedObject *m_managedObject;
    NSString *m_fieldName;
    id<UITextFieldDelegate> m_delegate;
    id<HLSTextFieldValidationDelegate> m_validationDelegate;
}

/**
 * Initialize with a managed object and the field we want to validate
 */
- (id)initWithFieldName:(NSString *)fieldName ofManagedObject:(NSManagedObject *)managedObject;

/**
 * Object and field which have been bound to the validator
 */
@property (nonatomic, readonly, retain) NSManagedObject *managedObject;
@property (nonatomic, readonly, retain) NSString *fieldName;

/**
 * The delegate to forward UITextFieldDelegate events to after the validator has performed its work
 */
@property (nonatomic, assign) id<UITextFieldDelegate> delegate;

/**
 * The delegate to which validation events are sent
 */
@property (nonatomic, assign) id<HLSTextFieldValidationDelegate> validationDelegate;

@end
