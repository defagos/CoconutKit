//
//  HLSAssert.m
//  CoconutKit
//
//  Created by Samuel Défago on 3/1/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSAssert.h"

#import "NSObject+HLSExtensions.h"

@interface NSAssertionHandler (HLSAssertPrivate)

+ (BOOL)enumeration:(id<NSFastEnumeration>)enumeration containsOnlyObjectsOfClass:(Class)objectClass strict:(BOOL)strict;

@end

@implementation NSAssertionHandler (HLSAssert)

- (void)handleIncorrectObjectClass:(Class)objectClass 
                     inEnumeration:(id<NSFastEnumeration>)enumeration
                            strict:(BOOL)strict 
                          inMethod:(SEL)selector 
                            object:(id)object 
                              file:(NSString *)fileName 
                        lineNumber:(NSInteger)line
{
    if (! [NSAssertionHandler enumeration:enumeration containsOnlyObjectsOfClass:objectClass strict:strict]) {
        NSString *description = [NSString stringWithFormat:@"Only objects of %@ type %@ are expected in the collection %@",
                                 strict? @"*exact* " : @"",
                                 objectClass, 
                                 enumeration];
        [self handleFailureInMethod:selector 
                             object:object 
                               file:fileName
                         lineNumber:line
                        description:@"%@", description];
    }
}

- (void)handleIncorrectObjectClass:(Class)objectClass 
                     inEnumeration:(id<NSFastEnumeration>)enumeration
                            strict:(BOOL)strict 
                        inFunction:(NSString *)functionName 
                              file:(NSString *)fileName 
                        lineNumber:(NSInteger)line
{
    if (! [NSAssertionHandler enumeration:enumeration containsOnlyObjectsOfClass:objectClass strict:strict]) {
        NSString *description = [NSString stringWithFormat:@"Only objects of %@ type %@ are expected in the collection %@",
                                 strict? @"*exact* " : @"",
                                 objectClass,
                                 enumeration];
        [self handleFailureInFunction:functionName
                                 file:fileName
                           lineNumber:line
                          description:@"%@", description];
    }
}

@end

@implementation NSAssertionHandler (HLSAssertPrivate)

+ (BOOL)enumeration:(id<NSFastEnumeration>)enumeration containsOnlyObjectsOfClass:(Class)objectClass strict:(BOOL)strict
{
    if (strict) {
        for (id object in enumeration) {
            if (! [object isMemberOfClass:objectClass]) {
                return NO;
            }
        }  
    }
    else {
        for (id object in enumeration) {
            if (! [object isKindOfClass:objectClass]) {
                return NO;
            }
        } 
    }
    return YES;
}

@end
