//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

/**
 * View binding error codes
 */
typedef NS_ENUM(NSInteger, HLSViewBindingError) {
    HLSViewBindingErrorObjectTargetNotFound,            // No meaningful target could be found for the key path
    HLSViewBindingErrorInvalidTransformer,              // The transformer is invalid or could not be resolved
    HLSViewBindingErrorTransformation,                  // Transformation error
    HLSViewBindingErrorMissingType,                     // The object type is unknown
    HLSViewBindingErrorUnsupportedType,                 // The object type is unsupported
    HLSViewBindingErrorPending,                         // The status cannot be fully determined
    HLSViewBindingErrorUnsupportedOperation             // The operation (e.g. update) is not supported
};

/**
 * Common domain for view binding related errors
 */
OBJC_EXPORT NSString * const HLSViewBindingErrorDomain;

