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
 *   - document: Behavior undefined if a valid<fieldName>:error: is implemented manually
 *
 * Also add unit tests for:
 *   - managed object hierarchies
 *   - validation of relationships between managed objects
 */
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
 * Inject the improved validation extensions of NSManagedObject (disabled by default). You should not call this method
 * directly, use the HLSEnableNSManagedObjectValidation macro instead
 */
+ (void)injectValidation;

- (BOOL)checkValue:(id)value forKey:(NSString *)key error:(NSError **)pError;

- (BOOL)checkForConsistency:(NSError **)pError;
- (BOOL)checkForDelete:(NSError **)pError;

@end
