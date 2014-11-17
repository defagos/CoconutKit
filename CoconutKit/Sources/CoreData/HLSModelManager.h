//
//  HLSModelManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSFileManager.h"

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
 */
@interface HLSModelManager : NSObject

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the specified bundle,
 * or in the main bundle if nil) and saving data at the specified store path within an SQLite store (the store
 * file name bears the model name), created using the provided file manager (if nil, uses the HLSStandardFileManager
 * singleton). If the store file already exists it is reused
 * 
 * For information about the configuration and options parameters 
 * please refer to the documentation of
 *  - [NSPersistentStoreCoordinator addPersistentStoreWithType:configuration:URL:options:error:]
 */
+ (instancetype)SQLiteManagerWithModelFileName:(NSString *)modelFileName
                                      inBundle:(NSBundle *)bundle
                                 configuration:(NSString *)configuration
                                storeDirectory:(NSString *)storeDirectory
                                   fileManager:(HLSFileManager *)fileManager
                                       options:(NSDictionary *)options;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the specified bundle,
 * or in the main bundle if nil) and saving data in-memory
 * 
 * For information about the configuration and options parameters 
 * please refer to the documentation of
 *  - [NSPersistentStoreCoordinator addPersistentStoreWithType:configuration:URL:options:error:]
 */
+ (instancetype)inMemoryModelManagerWithModelFileName:(NSString *)modelFileName
                                             inBundle:(NSBundle *)bundle
                                        configuration:(NSString *)configuration
                                              options:(NSDictionary *)options;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the specified bundle,
 * or in the main bundle if nil) and saving data at the specified store path within a binary file (the store file
 * name bears the model name), created using the provided file manager  (if nil, uses the HLSStandardFileManager
 * singleton). If the store file already exists it is reused
 *
 * For information about the configuration and options parameters 
 * please refer to the documentation of
 *  - [NSPersistentStoreCoordinator addPersistentStoreWithType:configuration:URL:options:error:]
 */
+ (instancetype)binaryModelManagerWithModelFileName:(NSString *)modelFileName
                                           inBundle:(NSBundle *)bundle
                                      configuration:(NSString *)configuration
                                     storeDirectory:(NSString *)storeDirectory
                                        fileManager:(HLSFileManager *)fileManager
                                            options:(NSDictionary *)options;
/**
 * Return the file path of the file-based store for a model, searching in a given directory using the specified
 * file manager (or the HLSStandardFileManager singleton if nil). Return nil if not found. You usually do not
 * have to get this path explicitly, except e.g. if you want to cleanup a store by removing its corresponding file
 */
+ (NSString *)storeFilePathForModelFileName:(NSString *)modelFileName
                             storeDirectory:(NSString *)storeDirectory
                                fileManager:(HLSFileManager *)fileManager;

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
+ (BOOL)saveCurrentModelContext:(NSError *__autoreleasing *)pError;
+ (void)rollbackCurrentModelContext;
+ (void)deleteObjectFromCurrentModelContext:(NSManagedObject *)managedObject;

/**
 * Create a model manager using the model file given as parameter (lookup is performed in the specified bundle,
 * or in the main bundle if nil), and saving it in the specified directory, using the provided file manager (if
 * nil, the HLSStandardFileManager singleton instance is used).
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
- (instancetype)initWithModelFileName:(NSString *)modelFileName
                             inBundle:(NSBundle *)bundle
                            storeType:(NSString *)storeType
                        configuration:(NSString *)configuration
                       storeDirectory:(NSString *)storeDirectory
                          fileManager:(HLSFileManager *)fileManager
                              options:(NSDictionary *)options NS_DESIGNATED_INITIALIZER;
/**
 * Duplicate an existing manager
 */
- (HLSModelManager *)duplicate;

/**
 * Migrate the persistence store. See -[NSPersistentStoreCoordinator migratePersistentStore:toURL:options:withType:error:]
 * for more information. Due to implementation constraints, migration can only be performed to a file URL, no arbitrary
 * file manager can be specified
 */
- (BOOL)migrateStoreToURL:(NSURL *)url withStoreType:(NSString *)storeType error:(NSError *__autoreleasing *)pError;

/**
 * Access to Core Data internals
 */
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;

@end

@interface HLSModelManager (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
