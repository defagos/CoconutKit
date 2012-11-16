//
//  HLSTextFieldInternalDelegate.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * A UITextField cannot be its own delegate (this leads to infinite recursion when entering edit mode of a text field
 * which is its own delegate). In general, it is probably better to avoid having an object being its own delegate anyway. 
 * If we want to trap text field delegate events to perform additional tasks, we therefore need an additional object as 
 * delegate, and having the real text field delegate as this object's delegate. This is just the purpose of this (private) 
 * HLSTextFieldInternalDelegate class. To use it, simply inherit from it, and implement the delegate methods you need
 * (calling the super method in their implementation)
 *
 * Designated initializer: -initWithTextField:
 */
@interface HLSTextFieldInternalDelegate : NSObject <UITextFieldDelegate> {
@private
    UITextField *m_textField;
    id<UITextFieldDelegate> m_delegate;
}

- (id)initWithTextField:(UITextField *)textField;

/**
 * The text field which the internal delegate object is the delegate of
 */
@property (nonatomic, readonly, assign) UITextField *textField;       // weak ref. Detector lifetime is managed by the text field

/**
 * The real text field delegate as seen externally
 */
@property (nonatomic, assign) id<UITextFieldDelegate> delegate;

@end
