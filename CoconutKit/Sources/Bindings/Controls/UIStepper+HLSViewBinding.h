//
//  UIStepper+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UIStepper:
 *   - binds to NSNumber model values
 *   - displays and updates the underlying model value
 *   - does not animate updates
 */
@interface UIStepper (HLSViewBinding) <HLSViewBindingImplementation>

@end
