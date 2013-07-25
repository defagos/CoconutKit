//
//  Employee.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 16.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface Employee : NSObject

+ (NSString *)stringFromNumber:(NSNumber *)number;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSNumber *age;

@end
