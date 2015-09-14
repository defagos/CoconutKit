//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@interface Employee : NSObject

+ (NSArray *)employees;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSNumber *age;

@end
