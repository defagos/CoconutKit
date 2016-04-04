//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSDictionary+HLSExtensions.h"

#import "HLSAssert.h"

@implementation NSDictionary (HLSExtensions)

- (NSDictionary *)dictionaryBySettingObject:(id)object forKey:(id)key
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    dictionary[key] = object;
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
    HLSAssertObjectsInEnumerationAreKindOfClass(self.allKeys, NSString);

    NSMutableDictionary *overriddenDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    NSDictionary *environment = [NSProcessInfo processInfo].environment;
    for (NSString *key in environment.allKeys) {
        id environmentValue = environment[key];
        overriddenDictionary[key] = environmentValue;
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
    self[key] = object;
}

@end
