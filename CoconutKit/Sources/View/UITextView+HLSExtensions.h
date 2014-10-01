//
//  UITextView+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

@interface UITextView (HLSExtensions)

/**
 * If set to YES, the text view resigns its first responder status when the user taps outside it
 *
 * The default value is NO
 */
@property (nonatomic, assign, getter=isResigningFirstResponderOnTap) BOOL resigningFirstResponderOnTap;

@end
