//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIView+HLSViewBindingImplementation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Binding support for UISegmentedControl:
 *   - binds to NSNumber (integer) or NSInteger model values
 *   - displays and updates the underlying model value
 *   - does not animate updates
 *   - check (if not disabled via bindInputChecked) and update the value each time it is changed
 */
@interface UISegmentedControl (HLSViewBindingImplementation) <HLSViewBindingImplementation>

@end
