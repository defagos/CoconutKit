//
//  UILabel+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UILabel:
 *   - binds to NSString model values
 *   - displays the underlying model value, but cannot update it
 *   - does not animate updates
 */
@interface UILabel (HLSViewBindingImplementation) <HLSViewBindingImplementation>

@end
