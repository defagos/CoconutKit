//
//  NSObject+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSObject+HLSExtensions.h"

#import <objc/runtime.h>

@implementation NSObject (HLSExtensions)

+ (NSString *)className
{
    return [NSString stringWithUTF8String:class_getName([self class])];
}

- (NSString *)className
{
    return [NSString stringWithUTF8String:class_getName([self class])];
}

@end
