//
//  HLSModelManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSModelManager.h"

#import "HLSLogger.h"

static HLSModelManager *s_defaultModelManager = nil;

@interface HLSModelManager ()

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

+ (HLSModelManager *)setDefaultModelManager:(HLSModelManager *)modelManager
{
    HLSModelManager *previousDefaultModelManager = s_defaultModelManager;
    s_defaultModelManager = [modelManager retain];
    return [previousDefaultModelManager autorelease];
}

+ (HLSModelManager *)defaultModelManager
{
    return s_defaultModelManager;
}

+ (NSManagedObjectContext *)defaultModelContext
{
    if (! s_defaultModelManager) {
        HLSLoggerWarn(@"No default context has been installed. Nothing saved");
        return nil;
    }
    
    return s_defaultModelManager.managedObjectContext;
}

+ (BOOL)saveDefaultModelContext:(NSError **)pError
{
    if (! s_defaultModelManager) {
        HLSLoggerWarn(@"No default context has been installed. Nothing saved");
        return YES;
    }
    
    return [s_defaultModelManager.managedObjectContext save:pError];
}

+ (void)rollbackDefaultModelContext
{
    if (! s_defaultModelManager) {
        HLSLoggerWarn(@"No default context has been installed. Nothing to rollback");
        return;
    }
    
    [s_defaultModelManager.managedObjectContext rollback];
}

+ (id)copyObjectInDefaultModelContext:(NSManagedObject *)managedObject
{
    if (! s_defaultModelManager) {
        HLSLoggerWarn(@"No default context has been installed. Nothing to rollback");
        return nil;
    }
    
    return [s_defaultModelManager copyObject:managedObject];
}

+ (void)deleteObjectFromDefaultModelContext:(NSManagedObject *)managedObject
{
    if (! s_defaultModelManager) {
        HLSLoggerWarn(@"No default context has been installed. Nothing to delete");
        return;
    }
    
    [s_defaultModelManager.managedObjectContext deleteObject:managedObject];
}

#pragma mark Object creation and destruction

- (id)initWithModelFileName:(NSString *)modelFileName storeDirectory:(NSString *)storeDirectory
{
    if ((self = [super init])) {
        if (! [self initializeWithModelFileName:modelFileName storeDirectory:storeDirectory]) {
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

#pragma mark Creating object copies

- (id)copyObject:(NSManagedObject *)managedObject
{
    if ([managedObject managedObjectContext] != self.managedObjectContext) {
        HLSLoggerError(@"The object to be copied does not belong to the managed context");
        return nil;
    }
    
    // Return the object itself, in effect a shallow copy
    if (! [managedObject conformsToProtocol:@protocol(HLSManagedObjectCopying)]) {
        return managedObject;
    }
    
    NSManagedObject<HLSManagedObjectCopying> *managedObjectCopyable = (NSManagedObject<HLSManagedObjectCopying> *)managedObject;
        
    // Create the deep copy
    NSManagedObject *objectCopy = [NSEntityDescription insertNewObjectForEntityForName:managedObjectCopyable.entity.name
                                                                inManagedObjectContext:self.managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:managedObjectCopyable.entity.name
                                                         inManagedObjectContext:self.managedObjectContext];
    
    // Get keys to exclude (if any)
    NSSet *keysToExclude = nil;
    if ([managedObjectCopyable respondsToSelector:@selector(keysToExclude)]) {
        keysToExclude = [managedObjectCopyable keysToExclude];
    }
    
    // Attributes
    NSDictionary *attributes = [entityDescription attributesByName];
    for (NSString *attributeName in [attributes allKeys]) {
        if ([keysToExclude containsObject:attributeName]) {
            continue;
        }
        [objectCopy setValue:[managedObject valueForKey:attributeName] forKey:attributeName];
    }
    
    // Relationships
    NSDictionary *relationships = [entityDescription relationshipsByName];
    for (NSString *relationshipName in [relationships allKeys]) {
        if ([keysToExclude containsObject:relationshipName]) {
            continue;
        }
        
        // Deep copy owned objects implementing the NSManagedObjectCopying protocol
        NSRelationshipDescription *relationshipDescription = [relationships objectForKey:relationshipName];
        if ([relationshipDescription deleteRule] == NSCascadeDeleteRule) {
            if ([relationshipDescription isToMany]) {
                NSSet *ownedObjects = [managedObjectCopyable valueForKey:relationshipName];
                NSMutableSet *ownedObjectCopies = [NSMutableSet set];
                for (NSManagedObject *ownedObject in ownedObjects) {
                    NSManagedObject *ownedObjectCopy = [self copyObject:ownedObject];
                    if (! ownedObjectCopy) {
                        return nil;
                    }
                    [ownedObjectCopies addObject:ownedObjectCopy];
                }
                [objectCopy setValue:[NSSet setWithSet:ownedObjectCopies] forKey:relationshipName];
            }
            else {
                NSManagedObject *ownedObject = [managedObjectCopyable valueForKey:relationshipName];
                NSManagedObject *ownedObjectCopy = [self copyObject:ownedObject];
                [objectCopy setValue:ownedObjectCopy forKey:relationshipName];
            }
        }
        // Shallow copy in all other cases
        else {
            [objectCopy setValue:[managedObjectCopyable valueForKey:relationshipName] forKey:relationshipName];
        }
    }
    
    return objectCopy;
}

@end
