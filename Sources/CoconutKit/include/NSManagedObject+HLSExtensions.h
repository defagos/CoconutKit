//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Convenience methods to perform common Core Data operations on managed objects. Most methods appear in two versions:
 *   - a version expecting a managed object context parameter:  
 *   - a context-free version, which works with the current model manager associated with the current thread (see 
 *     HLSModelManager.h)
 * Working with model managers and context-free methods reduces errors and is the preferred way of interacting with 
 * Core Data in CoconutKit. You should therefore only used the methods expecting a context parameter if you directly
 * have or want to interact with a managed object context
 */
@interface NSManagedObject (HLSExtensions)

/**
 * When called on an NSManagedObject subclass, create a new instance of it (without context parameter, the current
 * HLSModelManager context is used)
 */
+ (instancetype)insertIntoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)insert;
/**
 * When called on an NSManagedObject subclass, query instances of it matching a predicate, sorting them using the
 * specified descriptors (without context parameter, the current HLSModelManager context is used)
 */
+ (nullable NSArray *)filteredObjectsUsingPredicate:(nullable NSPredicate *)predicate
                             sortedUsingDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (nullable NSArray *)filteredObjectsUsingPredicate:(nullable NSPredicate *)predicate
                             sortedUsingDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors;

+ (nullable NSArray *)filteredObjectsUsingPredicate:(nullable NSPredicate *)predicate
                              sortedUsingDescriptor:(nullable NSSortDescriptor *)sortDescriptor
                             inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (nullable NSArray *)filteredObjectsUsingPredicate:(nullable NSPredicate *)predicate
                              sortedUsingDescriptor:(nullable NSSortDescriptor *)sortDescriptor;

/**
 * When called on an NSManagedObject subclass, query all instances of it, sorting them using the specified descriptors
 * (without context parameter, the current HLSModelManager context is used)
 */
+ (nullable NSArray *)allObjectsSortedUsingDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (nullable NSArray *)allObjectsSortedUsingDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors;

+ (nullable NSArray *)allObjectsSortedUsingDescriptor:(nullable NSSortDescriptor *)sortDescriptor
                               inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (nullable NSArray *)allObjectsSortedUsingDescriptor:(nullable NSSortDescriptor *)sortDescriptor;

/**
 * When called on an NSManagedObject subclass, query all instances of it, without predictable ordering (without context 
 * parameter, the current HLSModelManager context is used)
 */
+ (nullable NSArray *)allObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (nullable NSArray *)allObjects;

/**
 * When called on an NSManagedObject subclass, deletes all of its instances (without context parameter, the current 
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
 * After the method successfully returns an object, you must still commit the changes by calling -save: on the
 * managed object context in which it was created.
 */
- (nullable __kindof NSManagedObject *)duplicate;

@end

NS_ASSUME_NONNULL_END
