//
//  UISegmentedControl+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 29/03/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UISegmentedControl:
 *   - binds to NSNumber model values
 *   - displays and updates the underlying model value
 *   - does not animate updates
 */
@interface UISegmentedControl (HLSViewBindingImplementation) <HLSViewBindingImplementation>

@end
