//
//  WKWebView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * WKWebView does not support bindings
 */
@interface WKWebView (HLSViewBinding) <HLSViewBindingImplementation>

@end
