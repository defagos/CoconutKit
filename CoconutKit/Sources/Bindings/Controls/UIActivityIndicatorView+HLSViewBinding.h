//
//  UIActivityIndicatorView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UIActivityIndicatorView:
 *   - binds to NSNumber (boolean) or BOOL model values
 *   - displays the underlying model value, but cannot update it
 *   - does not animate updates
 */
@interface UIActivityIndicatorView (HLSViewBinding) <HLSViewBindingImplementation>

@end
