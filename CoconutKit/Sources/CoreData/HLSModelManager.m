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

+ (NSMutableArray *)modelManagerStackForThread:(NSThread *)thread;
+ (HLSModelManager *)currentModelManagerForThread:(NSThread *)thread;
+ (HLSModelManager *)rootModelManagerForThread:(NSThread *)thread;

- (BOOL)initializeWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory;

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (NSManagedObjectModel *)managedObjectModelFromModelFileName:(NSString *)modelFileName;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorForManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                                                                    modelFileName:(NSString *)modelFileName
                                                                   storeDirectory:(NSString *)storeDirectory;
- (NSManagedObjectContext *)managedObjectContextForPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@implementation HLSModelManager

#pragma mark Class methods

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

- (id)initWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory reuse:(BOOL)reuse
{
    if ((self = [super init])) {
        // Delete any existing store
        // TODO: Cleanest way: Move and delete on success
        if (! reuse) {
            NSString *filePath = [[storeDirectory stringByAppendingPathComponent:modelFileName] stringByAppendingPathExtension:@"sqlite"];
            if (! [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL]) {
                HLSLoggerWarn(@"Unable to delete previously existing store at %@", filePath);
            }
        }
        
        if (! [self initializeWithModelFileName:modelFileName storeDirectory:storeDirectory]) {            
            [self release];
            return nil;
        }        
    }
    return self;
}

- (id)initWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory
{
    return [self initWithModelFileName:modelFileName storeDirectory:storeDirectory reuse:YES];
}

- (void)dealloc
{
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
    self.managedObjectContext = nil;
    
    [super dealloc];
}

- (BOOL)initializeWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory
{
    self.managedObjectModel = [self managedObjectModelFromModelFileName:modelFileName];
    if (! self.managedObjectModel) {
        return NO;
    }
    
    self.persistentStoreCoordinator = [self persistentStoreCoordinatorForManagedObjectModel:self.managedObjectModel
                                                                              modelFileName:modelFileName
                                                                             storeDirectory:storeDirectory];
    if (! self.persistentStoreCoordinator) {
        return NO;
    }
    
    self.managedObjectContext = [self managedObjectContextForPersistentStoreCoordinator:self.persistentStoreCoordinator];
    if (! self.managedObjectContext) {
        return NO;
    }
    
    return YES;
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
                                                                    modelFileName:(NSString *)modelFileName
                                                                   storeDirectory:(NSString *)storeDirectory
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel] autorelease];
    
    NSString *storeFileName = [modelFileName stringByAppendingPathExtension:@"sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:[storeDirectory stringByAppendingPathComponent:storeFileName]];
    
    // Enable lightweight data migration
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                             nil];
    
	NSError *error = nil;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                  configuration:nil
                                                                                            URL:storeURL
                                                                                        options:options
                                                                                          error:&error];
    if (! persistentStore) {
        HLSLoggerError(@"Failed to create persistent store. Reason: %@", [error localizedDescription]);
        return nil;
    }
    
    // Delete the old file
    NSString *oldStoreFileName = [NSString stringWithFormat:@"~%@", storeFileName];
    [[NSFileManager defaultManager] removeItemAtPath:[storeDirectory stringByAppendingPathComponent:oldStoreFileName] error:NULL];
    
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
