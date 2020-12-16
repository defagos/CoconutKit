//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * CoconutKit core error codes
 */
typedef NS_ENUM(NSInteger, HLSCoreError) {
    HLSCoreErrorMultipleErrors,                 // Several errors have been encountered
    HLSCoreErrorTransformation                  // Transformation error (e.g. because of bad input)
};

/**
 * Common domain for core errors
 */
extern NSString * const HLSCoreErrorDomain;

NS_ASSUME_NONNULL_END
