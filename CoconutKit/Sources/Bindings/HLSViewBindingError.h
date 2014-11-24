//
//  HLSViewBindingError.h
//  CoconutKit
//
//  Created by Samuel Defago on 18/11/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

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
extern NSString * const HLSViewBindingErrorDomain;

