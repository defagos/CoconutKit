//
//  UITextView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UITextView:
 *   - binds to NSString model values
 *   - displays and updates the underlying model value
 *   - does not animate updates
 */
@interface UITextView (HLSViewBindingImplementation) <HLSViewBindingImplementation>

@end
