//
//  HLSTextField.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/12/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Thin wrapper to UITextField adding standard useful functionality.
 *
 * TODO: We could add a button above the keyboard (or somewhere else) to allow fast switching between HLSTextFields 
 *       without having to hide the keyboard. A better approach would allow fast switching between UIResponders (e.g. 
 *       a picker view, a text field, etc.)
 *
 * Designated initializer: -initWithFrame:
 */
@interface HLSTextField : UITextField

/**
 * If set to YES, the text field relinquishes its first responder status (if it is the first responder)
 * Default value is YES
 */
@property (nonatomic, assign) BOOL resigningFirstResponderOnTap;

@end
