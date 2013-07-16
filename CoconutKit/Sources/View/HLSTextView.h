//
//  HLSTextView.h
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Lightweight UITextView subclass providing more functionalities
 */
@interface HLSTextView : UITextView

/**
 * The text to be displayed when the text view is empty. Default is nil
 */
@property (nonatomic, strong) NSString *placeholderText;

/**
 * The color of the placeholder text. Default is light gray
 */
@property (nonatomic, strong) UIColor *placeholderTextColor;

@end
