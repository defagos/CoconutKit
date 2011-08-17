//
//  HLSModelManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSManagedObjectCopying.h"

/**
 * A class collecting the usual Core Data bolierplate code, and providing some additional convenience methods.
 * If your application is single-threaded, the default model manager and the associated class methods usually
 * suffice. If your application is multi-threaded, you can easily generate additional model managers by
 * duplicating the one of your main thread (use the duplicate method).
 *
 * Designated initializer: initWithModelFileName:storeDirectory:
 */
@interface HLSModelManager : NSObject {
@private
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;
}

/**
 * Set a default model manager for convenient retrieval using the defaultModelManager class method. The method
 * returns the previously installed default model manager (nil if none)
 * The new object is retained, and the previous one is returned autoreleased
 */
+ (HLSModelManager *)setDefaultModelManager:(HLSModelManager *)modelManager;

/**
 * Return the default model manager installed using setDefaultModelManager:
 */
+ (HLSModelManager *)defaultModelManager;

/**
 * Convenience methods to deal with the default model manager
 */
+ (NSManagedObjectContext *)defaultModelContext;
+ (BOOL)saveDefaultModelContext:(NSError **)pError;
+ (void)rollbackDefaultModelContext;
+ (id)copyObjectInDefaultModelContext:(NSManagedObject *)managedObject;

/**
 * Convenience methods to deal with managed objects in the default model manager context
 */
+ (void)deleteObjectFromDefaultModelContext:(NSManagedObject *)managedObject;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the main bundle) and
 * saving data at the specified store path
 */
- (id)initWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory;

/**
 * Duplicate an existing manager, e.g. for use in a separate thread
 */
- (HLSModelManager *)duplicate;

@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, retain) NSManagedObjectContext *managedObjectContext;

/**
 * Method to create a copy of a managed object. The behavior is as follows:
 *   - if the object implements the HLSManagedObjectCopying protocol, a clone is created, otherwise
 *     the object itself is returned. In the context of reference counting, this is actually
 *     equivalent to a shallow copy (since an object is likely to acquire a reference to the returned
 *     object)
 *   - when creating the clone of an object implementing HLSManagedObjectCopying, all attributes and
 *     relationships are copied, except those excluded by implementing the keysToExclude protocol
 *     method. Copy is made as follows:
 *       * a shallow copy is performed for attributes
 *       * a deep copy is performed for relationships corresponding to ownership (= delete behavior set as
 *         cascade) of owned objects implementing the HLSManagedObjectCopying protocol. In all other cases, 
 *         a shallow copy is performed
 * Note that the object which is copied must belong to the model manager context. The copy which is
 * returned also belongs to the same context.
 *
 * The method returns an object iff successful (changes still have to be committed, though). If the 
 * method returns nil, you should rollback your changes as soon as possible to avoid saving changes in an
 * inconsistent state.
 */
- (id)copyObject:(NSManagedObject *)managedObject;

@end
