//
//  HLSModelManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSModelManager.h"

#import "HLSError.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"

@interface HLSModelManager ()

+ (NSString *)standardStoreFilePathForModelFileName:(NSString *)modelFileName 
                                          storeType:(NSString *)storeType 
                                     storeDirectory:(NSString *)storeDirectory;

+ (NSMutableArray *)modelManagerStackForThread:(NSThread *)thread;
+ (HLSModelManager *)currentModelManagerForThread:(NSThread *)thread;
+ (HLSModelManager *)rootModelManagerForThread:(NSThread *)thread;

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (NSManagedObjectModel *)managedObjectModelFromModelFileName:(NSString *)modelFileName;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorForManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                                                                        storeType:(NSString *)storeType 
                                                                    configuration:(NSString *)configuration 
                                                                              URL:(NSURL *)storeURL 
                                                                          options:(NSDictionary *)options;
- (NSManagedObjectContext *)managedObjectContextForPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@implementation HLSModelManager

#pragma mark Class methods

+ (HLSModelManager *)SQLiteManagerWithModelFileName:(NSString *)modelFileName
                                      configuration:(NSString *)configuration
                                     storeDirectory:(NSString *)storeDirectory
                                            options:(NSDictionary *)options
{
    return [[[[self class] alloc] initWithModelFileName:modelFileName
                                              storeType:NSSQLiteStoreType
                                          configuration:configuration
                                         storeDirectory:storeDirectory 
                                                options:options] autorelease];
}

+ (HLSModelManager *)inMemoryModelManagerWithModelFileName:(NSString *)modelFileName
                                             configuration:(NSString *)configuration 
                                                   options:(NSDictionary *)options
{
    return [[[[self class] alloc] initWithModelFileName:modelFileName 
                                              storeType:NSInMemoryStoreType 
                                          configuration:configuration 
                                         storeDirectory:nil 
                                                options:options] autorelease];
}

+ (HLSModelManager *)binaryModelManagerWithModelFileName:(NSString *)modelFileName
                                           configuration:(NSString *)configuration 
                                          storeDirectory:(NSString *)storeDirectory
                                                 options:(NSDictionary *)options
{
    return [[[[self class] alloc] initWithModelFileName:modelFileName 
                                              storeType:NSBinaryStoreType 
                                          configuration:configuration 
                                         storeDirectory:storeDirectory 
                                                options:options] autorelease];
}

+ (NSString *)storeFilePathForModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
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
    return [modelManagerStack firstObject_hls];
}

+ (NSManagedObjectContext *)currentModelContext
{
    return [self currentModelManager].managedObjectContext;
}

+ (BOOL)saveCurrentModelContext:(NSError **)pError
{
    NSManagedObjectContext *currentModelContext = [self currentModelContext];
    if (! currentModelContext) {
        if (pError) {
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
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

- (id)initWithModelFileName:(NSString *)modelFileName 
                  storeType:(NSString *)storeType 
              configuration:(NSString *)configuration 
             storeDirectory:(NSString *)storeDirectory
                    options:(NSDictionary *)options
{
    if ((self = [super init])) {
        self.managedObjectModel = [self managedObjectModelFromModelFileName:modelFileName];
        if (! self.managedObjectModel) {
            [self release];
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
                                                                                        options:options];
        if (! self.persistentStoreCoordinator) {
            [self release];
            return nil;
        }
        
        self.managedObjectContext = [self managedObjectContextForPersistentStoreCoordinator:self.persistentStoreCoordinator];
        if (! self.managedObjectContext) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
    self.managedObjectContext = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark Initialization

- (NSManagedObjectModel *)managedObjectModelFromModelFileName:(NSString *)modelFileName
{	
    NSString *modelFilePath = [[NSBundle mainBundle] pathForResource:modelFileName ofType:@"momd"];
    if (! modelFilePath) {
        HLSLoggerError(@"Model file not found in main bundle");
        return nil;
    }
    
    NSURL *modelFileURL = [NSURL fileURLWithPath:modelFilePath];
    return [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelFileURL] autorelease];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorForManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                                                                        storeType:(NSString *)storeType 
                                                                    configuration:(NSString *)configuration 
                                                                              URL:(NSURL *)storeURL 
                                                                          options:(NSDictionary *)options
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel] autorelease];
    
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
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:oldFilePath]
                && [fileManager removeItemAtPath:oldFilePath error:&deletionError]) {
            HLSLoggerInfo(@"The old store at %@ has been removed after successful migration", oldFilePath);
        }
    }
        
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContextForPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSManagedObjectContext *managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    return managedObjectContext;
}

#pragma mark Duplication

- (HLSModelManager *)duplicate
{
    // Duplicate the context, the rest is the same
    HLSModelManager *modelManager = [[[HLSModelManager alloc] init] autorelease];
    modelManager.managedObjectContext = [self managedObjectContextForPersistentStoreCoordinator:self.persistentStoreCoordinator];
    modelManager.managedObjectModel = self.managedObjectModel;
    modelManager.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return modelManager;
}

@end
