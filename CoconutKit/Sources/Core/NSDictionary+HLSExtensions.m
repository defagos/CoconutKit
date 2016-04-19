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
    NSMutableDictionary *dictionary = [self mutableCopy];
    dictionary[key] = object;
    return [dictionary copy];
}

- (NSDictionary *)dictionaryByRemovingObjectForKey:(id)key
{
    NSMutableDictionary *dictionary = [self mutableCopy];
    [dictionary removeObjectForKey:key];
    return [dictionary copy];
}

- (NSDictionary *)dictionaryByRemovingObjectsForKeys:(NSArray *)keyArray
{
    NSMutableDictionary *dictionary = [self mutableCopy];
    [dictionary removeObjectsForKeys:keyArray];
    return [dictionary copy];
}

- (NSDictionary *)dictionaryOverriddenWithEnvironment
{
    HLSAssertObjectsInEnumerationAreKindOfClass(self.allKeys, NSString);

    NSMutableDictionary *overriddenDictionary = [self mutableCopy];
    NSDictionary *environment = [NSProcessInfo processInfo].environment;
    for (NSString *key in environment.allKeys) {
        id environmentValue = environment[key];
        overriddenDictionary[key] = environmentValue;
    }
    return [overriddenDictionary copy];
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
