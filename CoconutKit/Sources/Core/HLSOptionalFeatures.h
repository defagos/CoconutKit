//
//  HLSOptionalFeatures.h
//  CoconutKit
//
//  Created by Samuel Défago on 03.07.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * A collection of macros to enable optional CoconutKit features you might not want in your application.
 * Simply call a macro at global scope to enable the corresponding feature. Good places are for example 
 * main.m or your application delegate .m file
 */

#import "NSManagedObject+HLSValidation.h"
#import "UIControl+HLSExclusiveTouch.h"
#import "UITextView+HLSCursorVisibility.h"

#define HLSEnableUITextViewCursorVisibility()                                                            \
    __attribute__ ((constructor)) void HLSEnableUITextViewCursorVisibilityConstructor(void)              \
    {                                                                                                    \
        @autoreleasepool {                                                                               \
            [UITextView enableCursorVisibility];                                                         \
        }                                                                                                \
    }

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
