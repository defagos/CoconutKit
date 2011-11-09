//
//  NSManagedObject+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable the UIControl injection early, disabling quasi-
 * simultaneous taps. Good places are for example main.m or your application delegate .m file
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

+ (void)injectValidation;

- (BOOL)checkCurrentValueForKey:(NSString *)key error:(NSError **)pError;
- (BOOL)checkCurrentValuesForKeys:(NSArray *)keys error:(NSError **)pError;         // Performs all validations, chain errors

- (BOOL)checkForConsistency:(NSError **)pError;
- (BOOL)checkForDelete:(NSError **)pError;

@end

@interface UIViewController (HLSManagedObjectValidation)

- (BOOL)checkBoundManagedObjectFields:(NSError **)pError;

@end

@interface UIView (HLSManagedObjectValidation)

- (BOOL)checkBoundManagedObjectFields:(NSError **)pError;

@end
