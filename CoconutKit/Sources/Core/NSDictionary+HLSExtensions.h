//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HLSExtensions)

/**
 * Return the receiver, to which object has been set for key
 */
- (NSDictionary *)dictionaryBySettingObject:(id)object forKey:(id)key;

/**
 * Return the receiver without the object designated by key
 */
- (NSDictionary *)dictionaryByRemovingObjectForKey:(id)key;

/**
 * Return the receiver without the objects designated by the keys and the array
 */
- (NSDictionary *)dictionaryByRemovingObjectsForKeys:(NSArray *)keyArray;

/**
 * Return the receiver, but merged with the dictionary returned by [[NSProcessInfo processInfo] environment]. This 
 * method can only be used for dictionaries whose keys are strings
 *
 * Can be very handy to provide default plist value overriding via environment variables, for example
 */
- (NSDictionary *)dictionaryOverriddenWithEnvironment;

@end

@interface NSMutableDictionary (HLSExtensions)

/**
 * Same as setObject:forKey:, but does not attempt to insert nil objects or keys
 */
- (void)safelySetObject:(id)object forKey:(id)key;

@end
