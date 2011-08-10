//
//  NSDictionary+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSDictionary (HLSExtensions)

/**
 * Return the receiver, to which object has been set for key
 */
- (id)dictionaryBySettingObject:(id)object forKey:(id)key;

/**
 * Return the receiver without the object designated by key
 */
- (id)dictionaryByRemovingObjectForKey:(id)key;

/**
 * Return the receiver without the objects designated by the keys and the array
 */
- (id)dictionaryByRemovingObjectsForKeys:(NSArray *)keyArray;

@end

@interface NSMutableDictionary (HLSExtensions)

/**
 * Same as setObject:forKey:, but does not attempt to insert nil objects or keys
 */
- (void)safelySetObject:(id)object forKey:(id)key;

@end
