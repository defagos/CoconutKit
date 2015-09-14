//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

/**
 * CoconutKit core error codes
 */
typedef NS_ENUM(NSInteger, HLSCoreError) {
    HLSCoreErrorMultipleErrors,                 // Several errors have been encountered
    HLSCoreErrorTransformation,                 // Transformation error (e.g. because of bad input)
    HLSCoreErrorCanceled                        // A process has been canceled
};

/**
 * Common domain for core errors
 */
extern NSString * const HLSCoreErrorDomain;
