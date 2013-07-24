//
//  UITextField+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface UITextField (HLSExtensions)

/**
 * If set to YES, the text field relinquishes its first responder status (if it is the first responder)
 * Default value is YES
 */
@property (nonatomic, assign) BOOL resigningFirstResponderOnTap;

/**
 * Return the text field which is the current first responder, otherwise nil
 */
+ (UITextField *)currentTextField;

@end
