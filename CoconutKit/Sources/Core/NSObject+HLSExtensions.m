//
//  NSObject+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSObject+HLSExtensions.h"

#import <objc/runtime.h>
#import "HLSLogger.h"

@implementation NSObject (HLSExtensions)

+ (NSString *)className
{
    return NSStringFromClass(self);
}

- (NSString *)className
{
    return @(class_getName([self class]));
}

- (BOOL)implementsProtocol:(Protocol *)protocol
{
    // Only interested in optional methods. Required methods are checked at compilation time
    unsigned int numberOfMethods = 0;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(protocol, NO /* optional only */, YES, &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; ++i) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL selector = methodDescription.name;
        if (! class_getInstanceMethod([self class], selector)) {
            HLSLoggerInfo(@"Class %@ does not implement method %@ of protocol %@", [self className], @(sel_getName(selector)), @(protocol_getName(protocol)));
            return NO;
        }
    }
    
    return YES;
}

@end
