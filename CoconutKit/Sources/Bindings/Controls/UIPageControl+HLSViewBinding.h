//
//  UIPageControl+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UIPageControl:
 *   - binds to NSNumber (integer) or NSInteger model values
 *   - displays and updates the underlying model value
 *   - does not animate updates
 * - check (if not disabled via bindInputChecked) and update the value each time it is changed
 */
@interface UIPageControl (HLSViewBinding) <HLSViewBindingImplementation>

@end
