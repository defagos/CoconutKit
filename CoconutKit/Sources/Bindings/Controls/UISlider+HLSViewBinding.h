//
//  UISlider+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 16/03/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UISlider:
 *   - binds to NSNumber (float) or float model values
 *   - displays and updates the underlying model value
 *   - can animate updates
 *   - check (if not disabled via bindInputChecked) and update the value each time it is changed
 */
@interface UISlider (HLSViewBindingImplementation) <HLSViewBindingImplementation>

@end
