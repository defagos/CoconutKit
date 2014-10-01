//
//  NSDictionary+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSDictionary+HLSExtensions.h"

#import "HLSAssert.h"

@implementation NSDictionary (HLSExtensions)

- (NSDictionary *)dictionaryBySettingObject:(id)object forKey:(id)key
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    [dictionary setObject:object forKey:key];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSDictionary *)dictionaryByRemovingObjectForKey:(id)key
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    [dictionary removeObjectForKey:key];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSDictionary *)dictionaryByRemovingObjectsForKeys:(NSArray *)keyArray
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    [dictionary removeObjectsForKeys:keyArray];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSDictionary *)dictionaryOverriddenWithEnvironment
{
    HLSAssertObjectsInEnumerationAreKindOfClass([self allKeys], NSString);

    NSMutableDictionary *overriddenDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    for (NSString *key in [environment allKeys]) {
        id environmentValue = [environment objectForKey:key];
        [overriddenDictionary setObject:environmentValue forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:overriddenDictionary];
}

@end

@implementation NSMutableDictionary (HLSExtensions)

- (void)safelySetObject:(id)object forKey:(id)key
{
    if (! object || ! key) {
        return;
    }
    [self setObject:object forKey:key];
}

@end
