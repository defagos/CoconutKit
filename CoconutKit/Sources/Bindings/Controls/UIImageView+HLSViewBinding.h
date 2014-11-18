//
//  UIImageView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * Binding support for UIImageView:
 *   - binds to UIImage, NSString (image name in bundle, or path to image) or NSURL model values (file URL to image)
 *   - displays the underlying model value, but cannot update it
 *   - does not animate updates
 */
@interface UIImageView (HLSViewBinding) <HLSViewBindingImplementation>

@end
