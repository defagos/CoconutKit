//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIView+HLSViewBindingImplementation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Binding support for UIActivityIndicatorView:
 *   - binds to NSNumber (boolean) or BOOL model values
 *   - displays the underlying model value, but cannot update it
 *   - does not animate updates
 */
@interface UIActivityIndicatorView (HLSViewBinding) <HLSViewBindingImplementation>
@end

NS_ASSUME_NONNULL_END
