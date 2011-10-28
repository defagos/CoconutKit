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
 *   - only one single method for consistency check during updates / inserts (checkForConsistency:)
 *   - no more inout parameter for value to validate. As said in the Core Data doc, changing the value could lead
 *     to potentially serious memory management issues
 *   - never call validations defined in the model object. Call the validate method provided below (which takes
 *     into account validations defined in the xcdatamodel)
 *   - to be documented: Check methods always receive *pError = nil when called. The implementation must replace it with
 *     an error on validation failure. These methods are never to be called directly. Therefore, no need to check pError
 *     in them, the implementation can directly assign *pError without testing if pError != NULL
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

- (BOOL)checkValue:(id)value forKey:(NSString *)key error:(NSError **)pError;

- (BOOL)checkForConsistency:(NSError **)pError;
- (BOOL)checkForDelete:(NSError **)pError;

@end
