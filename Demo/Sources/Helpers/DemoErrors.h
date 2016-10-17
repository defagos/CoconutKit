//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DemoError) {
    DemoMandatoryError,
    DemoIncorrectError,
    DemoInputError
};

extern NSString * const DemoErrorDomain;

NS_ASSUME_NONNULL_END
