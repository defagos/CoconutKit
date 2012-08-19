//
//  NSObject+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
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
    return [NSString stringWithUTF8String:class_getName([self class])];
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
            NSString *selectorString = [NSString stringWithCString:(char *)selector encoding:NSUTF8StringEncoding];
            NSString *protocolName = [NSString stringWithCString:protocol_getName(protocol) encoding:NSUTF8StringEncoding];
            HLSLoggerInfo(@"Class %@ does not implement method %@ of protocol %@", [self className], selectorString, protocolName);
            selectorString = nil;               // Just to remove unused variable warnings
            protocolName = nil;
            return NO;
        }
    }
    
    return YES;
}

@end
