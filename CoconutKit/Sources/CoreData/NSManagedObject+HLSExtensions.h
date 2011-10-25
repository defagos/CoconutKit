//
//  NSManagedObject+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * TODO: Document:
 *   - naming scheme
 *   - never need to call [super check...] (unlike validate... methods). Extremely error-prone if forgotten
 *   - only one single method for consistency check during updates / inserts
 *   - probable: Validation settings set in the data model file are ignored. Not bad after all: Better to have it in code
 */
@interface NSManagedObject (HLSExtensions)

+ (id)insertIntoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (id)insert;

+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors
                    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors;

+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors
                       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors;

+ (NSArray *)allObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allObjects;

- (BOOL)checkForConsistency:(NSError **)pError;
- (BOOL)checkForDelete:(NSError **)pError;

@end
