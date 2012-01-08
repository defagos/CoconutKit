//
//  NSManagedObject+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface NSManagedObject (HLSExtensions)

/**
 * When called on an NSManagedObject subclass, create a new instance of it (without context parameter, the default
 * HLSModelManager context is used)
 */
+ (id)insertIntoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (id)insert;

/**
 * When called on an NSManagedObject subclass, query instances of it matching a predicate, sorting them using the
 * specified descriptors (without context parameter, the default HLSModelManager context is used)
 */
+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors
                    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors;

/**
 * When called on an NSManagedObject subclass, query all instances of it, sorting them using the specified descriptors
 * (without context parameter, the default HLSModelManager context is used)
 */
+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors
                       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors;

/**
 * When called on an NSManagedObject subclass, query all instances of it, without predictable ordering (without context 
 * parameter, the default HLSModelManager context is used)
 */
+ (NSArray *)allObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allObjects;

/**
 * When called on an NSManagedObject subclass, deletes all of its instances (without context parameter, the default 
 * HLSModelManager context is used)
 */
+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteAllObjects;

/**
 * Create a copy of the receiver if it implements the HLSManagedObjectCopying protocol. The copy is created in the same
 * managed object context which the receiver belongs to. If the receiver does not implement the HLSManagedObjectCopying
 * protocol, nil is returned.
 *
 * The copy is created as follows:
 *   - all attributes and relationships are copied, except when explicitly disabled by implementing the keysToExclude 
 *     property of the HLSManagedObjectCopying protocol
 *   - a shallow copy is performed for attributes
 *   - for relationships, a shallow copy is performed, except if the relationship corresponds to ownership of one
 *     or more objects also implementing the HLSManagedObjectCopying protocol (ownership is assumed when the relationship
 *     deletion behavior is set to cascade)
 *
 * After the method successfully returns an object, you must still commit the changes by calling save: on the
 * managed object context in which it was created.
 */
- (id)duplicate;

@end
