//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (HLSExtensions)

/**
 * Return the receiver, to which object has been set for key
 */
- (NSDictionary<KeyType, ObjectType> *)dictionaryBySettingObject:(ObjectType)object forKey:(KeyType)key;

/**
 * Return the receiver without the object designated by key
 */
- (NSDictionary<KeyType, ObjectType> *)dictionaryByRemovingObjectForKey:(KeyType)key;

/**
 * Return the receiver without the objects designated by the keys and the array
 */
- (NSDictionary<KeyType, ObjectType> *)dictionaryByRemovingObjectsForKeys:(NSArray<KeyType> *)keyArray;

/**
 * Return the receiver, but merged with the dictionary returned by [[NSProcessInfo processInfo] environment]. This 
 * method can only be used for dictionaries whose keys are strings
 *
 * Can be very handy to provide default plist value overriding via environment variables, for example
 */
- (NSDictionary<KeyType, ObjectType> *)dictionaryOverriddenWithEnvironment;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (HLSExtensions)

/**
 * Same as setObject:forKey:, but does not attempt to insert nil objects or keys
 */
- (void)safelySetObject:(nullable ObjectType)object forKey:(nullable KeyType)key;

@end

NS_ASSUME_NONNULL_END
