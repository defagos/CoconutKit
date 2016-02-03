//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIView+HLSViewBindingImplementation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Binding support for UIProgressView:
 *   - binds to NSNumber (float) or float model values
 *   - displays the underlying model value, but cannot update it
 *   - can animate updates
 */
@interface UIProgressView (HLSViewBindingImplementation) <HLSViewBindingImplementation>

@end
