//
//  UIButton+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Defago on 13/11/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * UIButton does not support bindings
 */
@interface UIButton (HLSViewBinding) <HLSViewBindingImplementation>

@end
