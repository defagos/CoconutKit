//
//  NSManagedObject+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable Core Data validation extensions early. Good places are 
 * for example main.m or your application delegate .m file
 */
#define HLSEnableNSManagedObjectValidation()                                                          \
    __attribute__ ((constructor)) void HLSEnableNSManagedObjectValidationConstructor(void)            \
    {                                                                                                 \
        [NSManagedObject injectValidation];                                                           \
    }

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

@end
