//
//  HLSTextFieldTouchDetector.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * A UITextField cannot be its own delegate (this leads to infinite recursion when entering edit mode of a text field
 * which is its own delegate). In general, it is probably better to avoid having an object being its own delegate anyway. 
 * If we want to trap text field delegate events to perform additional tasks (here trapping when edit mode is entered
 * or exited), we therefore need an  additional object as delegate, and having the real text field delegate as this 
 * object's delegate. This is just the purpose of this (private) HLSTextFieldTouchDetector class, which sets up touch
 * detection when edit mode is entered, and removes it when edit mode is exited. This allows us to detect when the
 * user taps outside a text field in edit mode (in such cases, we exit edit mode)
 *
 * Designated initializer: initWithTextField:
 */
@interface HLSTextFieldTouchDetector : NSObject <UITextFieldDelegate> {
@private
    UITextField *m_textField;
    UIGestureRecognizer *m_gestureRecognizer;
    id<UITextFieldDelegate> m_delegate;
}

- (id)initWithTextField:(UITextField *)textField;

@property (nonatomic, assign) id<UITextFieldDelegate> delegate;

@end
