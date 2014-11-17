//
//  HLSModelManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSModelManager.h"

#import "HLSFileManager.h"
#import "HLSLogger.h"
#import "HLSStandardFileManager.h"
#import "NSArray+HLSExtensions.h"
#import "NSError+HLSExtensions.h"

@interface HLSModelManager ()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HLSModelManager

#pragma mark Class methods

+ (instancetype)SQLiteManagerWithModelFileName:(NSString *)modelFileName
                                      inBundle:(NSBundle *)bundle
                                 configuration:(NSString *)configuration
                                storeDirectory:(NSString *)storeDirectory
                                   fileManager:(HLSFileManager *)fileManager
                                       options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithModelFileName:modelFileName
                                              inBundle:bundle
                                             storeType:NSSQLiteStoreType
                                         configuration:configuration
                                        storeDirectory:storeDirectory
                                           fileManager:fileManager
                                               options:options];
}

+ (instancetype)inMemoryModelManagerWithModelFileName:(NSString *)modelFileName
                                             inBundle:(NSBundle *)bundle
                                        configuration:(NSString *)configuration
                                              options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithModelFileName:modelFileName
                                              inBundle:bundle
                                             storeType:NSInMemoryStoreType
                                         configuration:configuration
                                        storeDirectory:nil
                                           fileManager:nil
                                               options:options];
}

+ (instancetype)binaryModelManagerWithModelFileName:(NSString *)modelFileName
                                           inBundle:(NSBundle *)bundle
                                      configuration:(NSString *)configuration
                                     storeDirectory:(NSString *)storeDirectory
                                        fileManager:(HLSFileManager *)fileManager
                                            options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithModelFileName:modelFileName
                                              inBundle:bundle
                                             storeType:NSBinaryStoreType
                                         configuration:configuration
                                        storeDirectory:storeDirectory
                                           fileManager:fileManager
                                               options:options];
}

+ (NSString *)storeFilePathForModelFileName:(NSString *)modelFileName
                             storeDirectory:(NSString *)storeDirectory
                                fileManager:(HLSFileManager *)fileManager
{
    // Look for a SQLite file
    NSString *sqliteFilePath = [self standardStoreFilePathForModelFileName:modelFileName
                                                                 storeType:NSSQLiteStoreType
                                                            storeDirectory:storeDirectory];
    if ([fileManager fileExistsAtPath:sqliteFilePath]) {
        return sqliteFilePath;
    }
    
    // Look for a binary file
    NSString *binaryFilePath = [self standardStoreFilePathForModelFileName:modelFileName
                                                                 storeType:NSBinaryStoreType
                                                            storeDirectory:storeDirectory];
    if ([fileManager fileExistsAtPath:binaryFilePath]) {
        return binaryFilePath;
    }
    
    // Not found
    return nil;
}

// Return the standard path for a store given its type and a model name
+ (NSString *)standardStoreFilePathForModelFileName:(NSString *)modelFileName
                                          storeType:(NSString *)storeType
                                     storeDirectory:(NSString *)storeDirectory
{
    NSString *extension = nil;
    if ([storeType isEqualToString:NSSQLiteStoreType]) {
        extension = @"sqlite";
    }
    else if ([storeType isEqualToString:NSBinaryStoreType]) {
        extension = @"bin";
    }
    else {
        return nil;
    }
    
    return [[storeDirectory stringByAppendingPathComponent:modelFileName] stringByAppendingPathExtension:extension];
}

+ (void)pushModelManager:(HLSModelManager *)modelManager
{
    if (! modelManager) {
        HLSLoggerError(@"Missing model manager");
        return;
    }
    
    NSMutableArray *modelManagerStack = [self modelManagerStackForThread:[NSThread currentThread]];
    [modelManagerStack addObject:modelManager];
}

+ (void)popModelManager
{
    NSMutableArray *modelManagerStack = [self modelManagerStackForThread:[NSThread currentThread]];
    if ([modelManagerStack count] == 0) {
        HLSLoggerInfo(@"No model manager to pop");
        return;
    }
    
    [modelManagerStack removeLastObject];
}

+ (NSMutableArray *)modelManagerStackForThread:(NSThread *)thread
{
    static NSString * const HLSModelManagerStackThreadLocalStorageKey = @"HLSModelManagerStackThreadLocalStorageKey";
    
    NSMutableArray *modelManagerStack = [[thread threadDictionary] objectForKey:HLSModelManagerStackThreadLocalStorageKey];
    if (! modelManagerStack) {
        modelManagerStack = [NSMutableArray array];
        [[thread threadDictionary] setObject:modelManagerStack forKey:HLSModelManagerStackThreadLocalStorageKey];
    }
    return modelManagerStack;
}

+ (HLSModelManager *)currentModelManager
{
    return [self currentModelManagerForThread:[NSThread currentThread]];
}

+ (HLSModelManager *)currentModelManagerForMainThread
{
    return [self currentModelManagerForThread:[NSThread mainThread]];
}

+ (HLSModelManager *)currentModelManagerForThread:(NSThread *)thread
{
    NSMutableArray *modelManagerStack = [self modelManagerStackForThread:thread];
    return [modelManagerStack lastObject];
}

+ (HLSModelManager *)rootModelManager
{
    return [self rootModelManagerForThread:[NSThread currentThread]];
}

+ (HLSModelManager *)rootModelManagerForMainThread
{
    return [self rootModelManagerForThread:[NSThread mainThread]];
}

+ (HLSModelManager *)rootModelManagerForThread:(NSThread *)thread
{
    NSMutableArray *modelManagerStack = [self modelManagerStackForThread:thread];
    return [modelManagerStack firstObject];
}

+ (NSManagedObjectContext *)currentModelContext
{
    return [self currentModelManager].managedObjectContext;
}

+ (BOOL)saveCurrentModelContext:(NSError *__autoreleasing *)pError
{
    NSManagedObjectContext *currentModelContext = [self currentModelContext];
    if (! currentModelContext) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSCoreDataError];
        }
        HLSLoggerError(@"No current context");
        return NO;
    }
    
    return [currentModelContext save:pError];
}

+ (void)rollbackCurrentModelContext
{
    NSManagedObjectContext *currentModelContext = [self currentModelContext];
    if (! currentModelContext) {
        HLSLoggerError(@"No current context");
        return;
    }
    
    [currentModelContext rollback];
}

+ (void)deleteObjectFromCurrentModelContext:(NSManagedObject *)managedObject
{
    NSManagedObjectContext *currentModelContext = [self currentModelContext];
    if (! currentModelContext) {
        HLSLoggerError(@"No current context");
        return;
    }
    
    [currentModelContext deleteObject:managedObject];
}

#pragma mark Object creation and destruction

- (instancetype)initWithModelFileName:(NSString *)modelFileName
                             inBundle:(NSBundle *)bundle
                            storeType:(NSString *)storeType
                        configuration:(NSString *)configuration
                       storeDirectory:(NSString *)storeDirectory
                          fileManager:(HLSFileManager *)fileManager
                              options:(NSDictionary *)options
{
    if (self = [super init]) {
        if (! fileManager) {
            fileManager = [HLSStandardFileManager defaultManager];
        }
        
        self.managedObjectModel = [self managedObjectModelFromModelFileName:modelFileName inBundle:bundle];
        if (! self.managedObjectModel) {
            return nil;
        }
        
        NSURL *standardStoreURL = nil;
        if (storeDirectory) {
            NSString *standardStoreFilePath = [HLSModelManager standardStoreFilePathForModelFileName:modelFileName
                                                                                           storeType:storeType
                                                                                      storeDirectory:storeDirectory];
            standardStoreURL = [NSURL fileURLWithPath:standardStoreFilePath];
        }
        self.persistentStoreCoordinator = [self persistentStoreCoordinatorForManagedObjectModel:self.managedObjectModel
                                                                                      storeType:storeType
                                                                                  configuration:configuration
                                                                                            URL:standardStoreURL
                                                                                        options:options
                                                                                    fileManager:fileManager];
        if (! self.persistentStoreCoordinator) {
            return nil;
        }
        
        self.managedObjectContext = [self managedObjectContextForPersistentStoreCoordinator:self.persistentStoreCoordinator];
        if (! self.managedObjectContext) {
            return nil;
        }
    }
    return self;
}

#pragma mark Initialization

- (NSManagedObjectModel *)managedObjectModelFromModelFileName:(NSString *)modelFileName inBundle:(NSBundle *)bundle
{
    if (! bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    NSString *modelFilePath = [bundle pathForResource:modelFileName ofType:@"momd"];
    if (! modelFilePath) {
        HLSLoggerError(@"Model file not found in main bundle");
        return nil;
    }
    
    NSURL *modelFileURL = [NSURL fileURLWithPath:modelFilePath];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelFileURL];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorForManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                                                                        storeType:(NSString *)storeType
                                                                    configuration:(NSString *)configuration
                                                                              URL:(NSURL *)storeURL
                                                                          options:(NSDictionary *)options
                                                                      fileManager:(HLSFileManager *)fileManager
{
    if (! fileManager) {
        fileManager = [HLSStandardFileManager defaultManager];
    }
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSError *error = nil;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                                                  configuration:configuration
                                                                                            URL:storeURL
                                                                                        options:options
                                                                                          error:&error];
    if (! persistentStore) {
        HLSLoggerError(@"Failed to create persistent store. Reason: %@", [error localizedDescription]);
        return nil;
    }
    
    // If migration of a file-based store has successfully been performed, delete the old file
    if ([storeURL isFileURL]) {
        NSString *fileURLString = [storeURL absoluteString];
        NSString *oldFileName = [NSString stringWithFormat:@"~%@", [fileURLString lastPathComponent]];
        NSString *oldFilePath = [[fileURLString stringByDeletingLastPathComponent] stringByAppendingPathComponent:oldFileName];
        
        NSError *deletionError = nil;
        if ([fileManager fileExistsAtPath:oldFilePath]
            && [fileManager removeItemAtPath:oldFilePath error:&deletionError]) {
            HLSLoggerInfo(@"The old store at %@ has been removed after successful migration", oldFilePath);
        }
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContextForPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    return managedObjectContext;
}

#pragma mark Duplication

- (HLSModelManager *)duplicate
{
    // Duplicate the context, the rest is the same
    HLSModelManager *modelManager = [[[self class] alloc] init];
    modelManager.managedObjectContext = [self managedObjectContextForPersistentStoreCoordinator:self.persistentStoreCoordinator];
    modelManager.managedObjectModel = self.managedObjectModel;
    modelManager.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return modelManager;
}

- (BOOL)migrateStoreToURL:(NSURL *)url withStoreType:(NSString *)storeType error:(NSError *__autoreleasing *)pError
{
    NSPersistentStore *persistentStore = [[self.persistentStoreCoordinator persistentStores] firstObject];
    return [self.persistentStoreCoordinator migratePersistentStore:persistentStore toURL:url options:nil withType:storeType error:pError] != nil;
}

@end
