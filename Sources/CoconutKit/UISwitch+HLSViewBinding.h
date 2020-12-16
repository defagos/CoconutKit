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
 * Binding support for UISwitch:
 *   - binds to NSNumber (boolean) or BOOL model values
 *   - displays and updates the underlying model value
 *   - can animate updates
 *   - check (if not disabled via bindInputChecked) and update the value each time it is changed
 */
@interface UISwitch (HLSViewBindingImplementation) <HLSViewBindingImplementation>
@end

NS_ASSUME_NONNULL_END
