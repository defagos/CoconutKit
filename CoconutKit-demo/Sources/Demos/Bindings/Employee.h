//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Employee : NSObject

+ (NSArray *)employees;

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic) NSNumber *age;

@end

NS_ASSUME_NONNULL_END
