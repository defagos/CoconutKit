//
//  HLSCoreError.h
//  CoconutKit
//
//  Created by Samuel Defago on 18/11/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

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




