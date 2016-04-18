//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSManagedObject+HLSValidation.h"
#import "UIControl+HLSExclusiveTouch.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Enable Core Data validation extensions. You need to enable this feature if you want the CoconutKit
 * central validations and text field bindings to be available. This feature does not incur any major 
 * overhead but swizzles several methods under the hood
 */
#define HLSEnableNSManagedObjectValidation()                                                             \
    __attribute__ ((constructor)) void HLSEnableNSManagedObjectValidationConstructor(void)               \
    {                                                                                                    \
        @autoreleasepool {                                                                               \
            [NSManagedObject enableObjectValidation];                                                    \
        }                                                                                                \
    }

/**
 * Prevent taps occuring quasi-simultaneously on several controls. This changes the default UIKit behavior
 * but can greatly improve your application robustness (having to deal with such taps can be quite a
 * nightmare and can lead to erratic behaviors or crashes when monkey-testing your application)
 */
#define HLSEnableUIControlExclusiveTouch()                                                               \
    __attribute__ ((constructor)) void HLSEnableUIControlExclusiveTouchConstructor(void)                 \
    {                                                                                                    \
        @autoreleasepool {                                                                               \
            [UIControl enableExclusiveTouch];                                                            \
        }                                                                                                \
    }

NS_ASSUME_NONNULL_END
