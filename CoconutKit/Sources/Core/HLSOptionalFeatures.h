//
//  HLSOptionalFeatures.h
//  CoconutKit
//
//  Created by Samuel Défago on 03.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A collection of macros to enable optional CoconutKit features you might not want in your application.
 * Simply call a macro at global scope to enable the corresponding feature. Good places are for example 
 * main.m or your application delegate .m file
 */

#import "HLSApplicationPreloader.h"
#import "NSManagedObject+HLSValidation.h"
#import "UIControl+HLSExclusiveTouch.h"

/**
 * Enable preloading of some objects (currently only UIWebView) when the application is started. This 
 * incurs a memory overhead you might not want to pay if you do not need those features (most notably 
 * if your application does not contain any UIWebView)
 */
#if !__has_feature(objc_arc)
#define HLSEnableApplicationPreloading()                                                                  \
    __attribute__ ((constructor)) void HLSEnableApplicationPreloadingConstructor(void)                    \
    {                                                                                                     \
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];                                       \
        [HLSApplicationPreloader enable];                                                                 \
        [pool drain];                                                                                     \
    }
#else
#define HLSEnableApplicationPreloading()                                                                  \
    __attribute__ ((constructor)) void HLSEnableApplicationPreloadingConstructor(void)                    \
    {                                                                                                     \
        [HLSApplicationPreloader enable];                                                                 \
    }
#endif

/**
 * Enable Core Data validation extensions. You need to enable this feature if you want the CoconutKit
 * central validations and text field bindings to be available. This feature does not incur any major 
 * overhead but swizzles several methods under the hood
 */
#if !__has_feature(objc_arc)
#define HLSEnableNSManagedObjectValidation()                                                             \
    __attribute__ ((constructor)) void HLSEnableNSManagedObjectValidationConstructor(void)               \
    {                                                                                                    \
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];                                      \
        [NSManagedObject enable];                                                                        \
        [pool drain];                                                                                    \
    }
#else
#define HLSEnableNSManagedObjectValidation()                                                             \
    __attribute__ ((constructor)) void HLSEnableNSManagedObjectValidationConstructor(void)               \
    {                                                                                                    \
        [NSManagedObject enable];                                                                        \
    }
#endif

/**
 * Prevent taps occuring quasi-simultaneously on several controls. This changes the default UIKit behavior
 * but can greatly improve your application robustness (having to deal with such taps can be quite a
 * nightmare and can lead to erratic behaviors or crashes when monkey-testing your application)
 */
#if !__has_feature(objc_arc)
#define HLSEnableUIControlExclusiveTouch()                                                               \
    __attribute__ ((constructor)) void HLSEnableUIControlExclusiveTouchConstructor(void)                 \
    {                                                                                                    \
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];                                      \
        [UIControl enable];                                                                              \
        [pool drain];                                                                                    \
    }
#else
#define HLSEnableUIControlExclusiveTouch()                                                               \
    __attribute__ ((constructor)) void HLSEnableUIControlExclusiveTouchConstructor(void)                 \
    {                                                                                                    \
        [UIControl enable];                                                                              \
    }
#endif
