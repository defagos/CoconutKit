//
//  Employee.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 16.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

@interface Employee : NSObject

+ (NSArray *)employees;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSNumber *age;

@end
