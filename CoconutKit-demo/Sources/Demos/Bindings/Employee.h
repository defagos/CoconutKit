//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

@interface Employee : NSObject

+ (NSArray *)employees;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSNumber *age;

@end
