//
//  UITextView+HLSCursorVisibility.h
//  CoconutKit
//
//  Created by Samuel Défago on 29.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

/**
 * Globally ensure that the text view cursor stays in the area defined by its content insets
 *
 * Remark: Calling this method does nothing starting with iOS 8 since this behavior is natively implemented
 */
@interface UITextView (HLSCursorVisibility)

/**
 * Call this method as soon as possible to toggle cursor visibility for all text views. For simplicity you 
 * should use the HLSEnableUITextViewCursorVisibility convenience macro instead (see HLSOptionalFeatures.h)
 */
+ (void)enableCursorVisibility;

@end
