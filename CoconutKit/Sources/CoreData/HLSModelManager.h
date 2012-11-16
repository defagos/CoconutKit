//
//  HLSModelManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Standard option combinations
#define HLSModelManagerLightweightMigrationOptions          [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,   \
                                                                                                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,         \
                                                                                                       nil]

/**
 * A model manager is a lightweight wrapper around a Core Data managed object context, eliminating most of the 
 * usual boilerplate you have to write when creating stores and contexts, and providing some additional convenience 
 * methods to make your life easier.
 *
 * Several model managers can coexist in an application. Two design rationales have been taken into account:
 *   - you usually interact with one managed object context per thread. You may need to create another one, 
 *     but interaction should be restricted to one context at a time. Note that this is a best practice, not 
 *     a Core Data technical limitation
 *   - Core Data contexts must not be shared among threads
 *   - contexts rarely need to be accessed directly. Database operations should therefore implicitly always 
 *     be performed in the current thread's active context
 * 
 * Based on those rationales, HLSModelManager provides a way to manage a stack of model manager objects (i.e. 
 * of contexts) on a thread basis. You now simply push the model manager you want to work with onto the stack and
 * call context-free methods from NSManagedObject+HLSExtensions.h to act on it. This eliminates the need to
 * refer to managed object contexts explicitly, which is error-prone, especially in the context of multithreaded
 * applications.
 *
 * As a programmer you are most likely to use model managers as follows:
 *   - create a model manager on the main thread, and push it onto the main thread model manager stack
 *   - perform database operations using the context-free methods of NSManagedObject+HLSExtensions.h
 *   - if you need to work in another context, duplicate the current model manager (by calling the -duplicate
 *     method) and push the new instance onto the stack. Perform database operations using the context-free 
 *     methods of NSManagedObject+HLSExtensions.h. When you are done, pop the current model manager off the 
 *     stack
 *   - go on working with the previously pushed model manager
 *   - if you need to perform database operations on another thread, duplicate the current context and push 
 *     the new instance onto the other thread model manager stack
 *
 * Designated initializer: -initWithModelFileName:storeType:configuration:storeDirectory:options:
 */
@interface HLSModelManager : NSObject {
@private
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;
}

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the main bundle) and
 * saving data at the specified store path within an SQLite store (the store file name bears the model name). 
 * If the store file already exists it is reused
 * 
 * For information about the configuration and options parameters 
 * please refer to the documentation of
 *  - [NSPersistentStoreCoordinator addPersistentStoreWithType:configuration:URL:options:error:]
 */
+ (HLSModelManager *)SQLiteManagerWithModelFileName:(NSString *)modelFileName
                                      configuration:(NSString *)configuration
                                     storeDirectory:(NSString *)storeDirectory
                                            options:(NSDictionary *)options;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the main bundle) and
 * saving data in-memory
 * 
 * For information about the configuration and options parameters 
 * please refer to the documentation of
 *  - [NSPersistentStoreCoordinator addPersistentStoreWithType:configuration:URL:options:error:]
 */
+ (HLSModelManager *)inMemoryModelManagerWithModelFileName:(NSString *)modelFileName
                                             configuration:(NSString *)configuration 
                                                   options:(NSDictionary *)options;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the main bundle) and
 * saving data at the specified store path within a binary file (the store file name bears the model name).
 * If the store file already exists it is reused
 *
 * For information about the configuration and options parameters 
 * please refer to the documentation of
 *  - [NSPersistentStoreCoordinator addPersistentStoreWithType:configuration:URL:options:error:]
 */
+ (HLSModelManager *)binaryModelManagerWithModelFileName:(NSString *)modelFileName
                                           configuration:(NSString *)configuration 
                                          storeDirectory:(NSString *)storeDirectory
                                                 options:(NSDictionary *)options;
/**
 * Return the file path of the file-based store for a model, searching in a given directory. Return nil if not
 * found. You usually do not have to get this path explicitly, except e.g. if you want to cleanup a store
 * by removing its corresponding file
 */
+ (NSString *)storeFilePathForModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory;

/**
 * Manage the stack of model managers attached to the current thread
 */
+ (void)pushModelManager:(HLSModelManager *)modelManager;
+ (void)popModelManager;

/**
 * Return the model manager at the top of model manager stack, for the current thread, respectively for the 
 * main thread
 */
+ (HLSModelManager *)currentModelManager;
+ (HLSModelManager *)currentModelManagerForMainThread;

/**
 * Return the model manager at the bottom of model manager stack, for the current thread, respectively for the 
 * main thread
 */
+ (HLSModelManager *)rootModelManager;
+ (HLSModelManager *)rootModelManagerForMainThread;

/**
 * Convenience methods to work with the current model manager context
 */
+ (NSManagedObjectContext *)currentModelContext;
+ (BOOL)saveCurrentModelContext:(NSError **)pError;
+ (void)rollbackCurrentModelContext;
+ (void)deleteObjectFromCurrentModelContext:(NSManagedObject *)managedObject;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the main bundle), and
 * saving it in the specified directory. 
 * 
 * For information about the storeType, configuration and options parameters 
 * please refer to the documentation of
 *  - [NSPersistentStoreCoordinator addPersistentStoreWithType:configuration:URL:options:error:]
 *
 * If migration of an existing file-based store is performed and succeeds, the old backup store file is automatically
 * deleted.
 *
 * Convenience constructors have been provided for easy instantiation of the most common store types and are the
 * preferred way of instantiating model managers.
 */
- (id)initWithModelFileName:(NSString *)modelFileName 
                  storeType:(NSString *)storeType 
              configuration:(NSString *)configuration 
             storeDirectory:(NSString *)storeDirectory
                    options:(NSDictionary *)options;
/**
 * Duplicate an existing manager
 */
- (HLSModelManager *)duplicate;

/**
 * Access to Core Data internals
 */
@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, retain) NSManagedObjectContext *managedObjectContext;

@end
