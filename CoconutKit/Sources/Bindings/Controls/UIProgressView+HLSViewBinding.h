//
//  UIProgressView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 07/03/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UIProgressView:
 *   - binds to NSNumber (float) or float model values
 *   - displays the underlying model value, but cannot update it
 *   - can animate updates
 */
@interface UIProgressView (HLSViewBindingImplementation) <HLSViewBindingImplementation>

@end
