//
//  UIDatePicker+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 05.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UIDatePicker:
 *   - binds to NSDate model values
 *   - displays and updates the underlying model value
 *   - can animate updates
 *   - check (if not disabled via bindInputChecked) and update the value each time it is changed
 */
@interface UIDatePicker (HLSViewBinding)

@end
