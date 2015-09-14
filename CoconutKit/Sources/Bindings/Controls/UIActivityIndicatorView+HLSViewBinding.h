//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIView+HLSViewBindingImplementation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Binding support for UIActivityIndicatorView:
 *   - binds to NSNumber (boolean) or BOOL model values
 *   - displays the underlying model value, but cannot update it
 *   - does not animate updates
 */
@interface UIActivityIndicatorView (HLSViewBinding) <HLSViewBindingImplementation>

@end
