//
//  NSObject+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSObject+HLSExtensions.h"

#import <objc/runtime.h>
#import "HLSCategoryLinker.h"

HLSLinkCategory(NSObject_HLSExtensions)

@implementation NSObject (HLSExtensions)

+ (NSString *)className
{
    return NSStringFromClass(self);
}

- (NSString *)className
{
    return [NSString stringWithUTF8String:class_getName([self class])];
}

@end
