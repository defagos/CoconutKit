//
//  HLSModelManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A class collecting the usual Core Data bolierplate code, and providing some additional convenience methods.
 * If your application is single-threaded, the default model manager and the associated class methods usually
 * suffice. If your application is multi-threaded, you can easily generate additional model managers by
 * duplicating the one of your main thread (use the duplicate method).
 *
 * Designated initializer: initWithModelFileName:storeDirectory:reuse:
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

/**
 * Convenience methods to deal with managed objects in the default model manager context
 */
+ (void)deleteObjectFromDefaultModelContext:(NSManagedObject *)managedObject;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the main bundle) and
 * saving data at the specified store path. If reuse is set to YES, any existing data store is reused (and
 * migrated if needed), otherwise the store is destroyed first
 */
- (id)initWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory reuse:(BOOL)reuse;

/**
 * Same as initWithModelFileName:storeDirectory:reuse:, with reuse set as YES (which is the value commonly used)
 */
- (id)initWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory;

/**
 * Duplicate an existing manager, e.g. for use in a separate thread
 */
- (HLSModelManager *)duplicate;

@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, retain) NSManagedObjectContext *managedObjectContext;

@end
