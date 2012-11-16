//
//  NSDictionary+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSDictionary+HLSExtensions.h"

@implementation NSDictionary (HLSExtensions)

- (id)dictionaryBySettingObject:(id)object forKey:(id)key
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    [dictionary setObject:object forKey:key];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (id)dictionaryByRemovingObjectForKey:(id)key
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    [dictionary removeObjectForKey:key];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (id)dictionaryByRemovingObjectsForKeys:(NSArray *)keyArray
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    [dictionary removeObjectsForKeys:keyArray];
    return [NSDictionary dictionaryWithDictionary:dictionary];
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
