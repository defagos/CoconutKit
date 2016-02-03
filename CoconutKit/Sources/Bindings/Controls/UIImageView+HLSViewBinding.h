//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIView+HLSViewBindingImplementation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Binding support for UIImageView:
 *   - binds to UIImage, NSString (image name in bundle, or path to image) or NSURL model values (file URL to image)
 *   - displays the underlying model value, but cannot update it
 *   - does not animate updates
 */
@interface UIImageView (HLSViewBinding) <HLSViewBindingImplementation>

@end
