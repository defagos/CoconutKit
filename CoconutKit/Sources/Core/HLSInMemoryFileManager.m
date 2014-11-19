//
//  HLSInMemoryFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.10.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSInMemoryFileManager.h"

#import "HLSInMemoryCacheEntry.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSString+HLSExtensions.h"

@interface HLSInMemoryFileManager ()

@property (nonatomic, strong) NSMutableDictionary *rootItems;           // Stores the directory / file hierarchy
@property (nonatomic, strong) NSCache *cache;                           // Store data

@end

@implementation HLSInMemoryFileManager

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.rootItems = [NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionary] forKey:@"/"];
        self.cache = [[NSCache alloc] init];
        self.cache.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Accessors and mutators

- (NSUInteger)byteCostLimit
{
    return self.cache.totalCostLimit;
}

- (void)setByteCostLimit:(NSUInteger)byteCostLimit
{
    self.cache.totalCostLimit = byteCostLimit;
}

#pragma mark Content management

/**
 * We use dictionaries to store directory structure and file names. A dictionary key is the name of a file or of a folder.
 * For folders, the corresponding value is a dictionary (which might be empty if the directory is empty). For files, the
 * value is a unique string identifier, pointing at the corresponding NSCache data entry
 *
 * Intermediate directories are created if they do not exist. If data is nil, a folder is added, otherwise a file
 */
- (BOOL)addObjectAtPath:(NSString *)path withData:(NSData *)data error:(NSError *__autoreleasing *)pError
{
    if (! [path hasPrefix:@"/"]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileReadInvalidFileNameError
                          localizedDescription:CoconutKitLocalizedString(@"Invalid file path", nil)];
        }
        return NO;
    }
    
    return [self addObjectAtPath:path toItems:self.rootItems withData:data error:pError];
}

- (BOOL)addObjectAtPath:(NSString *)path toItems:(NSMutableDictionary *)items withData:(NSData *)data error:(NSError *__autoreleasing *)pError
{
    NSArray *pathComponents = [path pathComponents];
    if ([pathComponents count] == 0) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"Invalid path", nil)];
        }
        return NO;
    }
    
    if ([pathComponents count] == 1) {
        NSString *objectName = [pathComponents firstObject];
        
        // File. If the file already exists, it will be replaced
        if (data) {
            NSString *oldUUID = [items objectForKey:objectName];
            if (oldUUID) {
                [self.cache removeObjectForKey:oldUUID];
            }
            
            HLSInMemoryCacheEntry *cacheEntry = [[HLSInMemoryCacheEntry alloc] initWithParentItems:items
                                                                                              name:objectName
                                                                                              data:data];
            
            NSString *UUID = [[NSUUID UUID] UUIDString];
            [items setObject:UUID forKey:objectName];
            [self.cache setObject:cacheEntry forKey:UUID cost:cacheEntry.cost];
        }
        // Folder. If the folder already exists, it is not replaced, and the method succeeds
        else {
            if (! [items objectForKey:objectName]) {
                [items setObject:[NSMutableDictionary dictionary] forKey:objectName];
            }
        }
        
        return YES;
    }
    else {
        NSString *firstPathComponent = [pathComponents firstObject];
        
        // Create intermediate directories if needed
        NSMutableDictionary *subitems = [items objectForKey:firstPathComponent];
        if (! subitems) {
            subitems = [NSMutableDictionary dictionary];
            [items setObject:subitems forKey:firstPathComponent];
        }
        
        // Go down one level deeper
        NSArray *subpathComponents = [pathComponents subarrayWithRange:NSMakeRange(1, [pathComponents count] - 1)];
        NSString *subpath = [NSString pathWithComponents:subpathComponents];
        return [self addObjectAtPath:subpath toItems:subitems withData:data error:pError];
    }
}

/**
 * Copy the object from sourceItems having the specified name, to the destination dictionary. Fails if the source
 * is not found or if the destination already exists
 */
- (BOOL)copyObjectWithName:(NSString *)sourceObjectName
                   inItems:(NSDictionary *)sourceItems
          toObjectWithName:(NSString *)destinationObjectName
                   inItems:(NSMutableDictionary *)destinationItems
                     error:(NSError *__autoreleasing *)pError
{
    // Retrieve the source content
    id sourceContent = [sourceItems objectForKey:sourceObjectName];
    if (! sourceContent) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"File or directory not found", nil)];
        }
        return NO;
    }
    
    if ([destinationItems objectForKey:destinationObjectName]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileWriteFileExistsError
                          localizedDescription:CoconutKitLocalizedString(@"The destination already exists", nil)];
        }
        return NO;
    }
    
    // Folder
    if ([sourceContent isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *destinationSubitems = [NSMutableDictionary dictionary];
        [destinationItems setObject:destinationSubitems forKey:destinationObjectName];
        
        for (NSString *subname in [sourceContent allKeys]) {
            if (! [self copyObjectWithName:subname inItems:sourceContent toObjectWithName:subname inItems:destinationSubitems error:pError]) {
                // FIXME: Should handle rollback more appropriately in case of failure!
                return NO;
            }
        }
                
        return YES;
    }
    // File UUID
    else {
        HLSInMemoryCacheEntry *sourceCacheEntry = [self.cache objectForKey:sourceContent];
        
        // Perform a deep copy of the source data
        HLSInMemoryCacheEntry *destinationCacheEntry = [[HLSInMemoryCacheEntry alloc] initWithParentItems:destinationItems
                                                                                                     name:destinationObjectName
                                                                                                     data:[sourceCacheEntry.data copy]];
        
        NSString *UUID = [[NSUUID UUID] UUIDString];
        [destinationItems setObject:UUID forKey:destinationObjectName];
        [self.cache setObject:destinationCacheEntry forKey:UUID cost:destinationCacheEntry.cost];
    }
    
    return YES;
}

- (BOOL)moveObjectWithName:(NSString *)sourceObjectName
                   inItems:(NSMutableDictionary *)sourceItems
          toObjectWithName:(NSString *)destinationObjectName
                   inItems:(NSMutableDictionary *)destinationItems
                     error:(NSError *__autoreleasing *)pError
{
    // Retrieve the source content
    id sourceContent = [sourceItems objectForKey:sourceObjectName];
    if (! sourceContent) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"File or directory not found", nil)];
        }
        return NO;
    }
    
    if ([destinationItems objectForKey:destinationObjectName]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileWriteFileExistsError
                          localizedDescription:CoconutKitLocalizedString(@"The destination already exists", nil)];
        }
        return NO;
    }
    
    // Unlink from source and link to destination folder. Very cheap
    [destinationItems setObject:sourceContent forKey:destinationObjectName];
    [sourceItems removeObjectForKey:sourceObjectName];
    
    return YES;
}

/**
 * Return either a dictionary (folder) or a string identifier pointing to a cache entry (file)
 */
- (id)contentAtPath:(NSString *)path forItems:(NSDictionary *)items
{
    NSArray *pathComponents = [path pathComponents];
    if ([pathComponents count] == 0) {
        return nil;
    }
    
    NSString *firstPathComponent = [pathComponents firstObject];
    id subitems = [items objectForKey:firstPathComponent];
    
    if ([pathComponents count] == 1) {
        return subitems;
    }
    else {
        NSArray *subpathComponents = [pathComponents subarrayWithRange:NSMakeRange(1, [pathComponents count] - 1)];
        NSString *subpath = [NSString pathWithComponents:subpathComponents];
        return [self contentAtPath:subpath forItems:subitems];
    }  
}

- (BOOL)removeItemWithName:(NSString *)name inItems:(NSMutableDictionary *)items error:(NSError *__autoreleasing *)pError
{
    id content = [items objectForKey:name];
    if (! content) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"File or directory not found", nil)];
        }
        return NO;
    }
    
    // Directory
    if ([content isKindOfClass:[NSDictionary class]]) {
        // Recursively remove content
        NSArray *subnames = [content allKeys];
        for (NSString *subname in subnames) {
            [self removeItemWithName:subname inItems:content error:NULL];
        }
    }
    // File
    else {
        [self.cache removeObjectForKey:content];
    }
    
    [items removeObjectForKey:name];
    return YES;
}

- (BOOL)checkParentDirectoryForPath:(NSString *)path error:(NSError *__autoreleasing *)pError
{
    BOOL isDirectory = NO;
    NSString *parentPath = [path stringByDeletingLastPathComponent];    
    if (! [self fileExistsAtPath:parentPath isDirectory:&isDirectory] || ! isDirectory) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:[NSString stringWithFormat:CoconutKitLocalizedString(@"The directory %@ does not exist", nil), parentPath]];
        }
        return NO;
    }
    return YES;
}

#pragma mark HLSFileManagerAbstract protocol implementation

- (NSData *)contentsOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError
{
    id content = [self contentAtPath:path forItems:self.rootItems];
    if (! content || ! [content isKindOfClass:[NSString class]]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"File not found", nil)];
        }
        return nil;
    }
    
    HLSInMemoryCacheEntry *cacheEntry = [self.cache objectForKey:content];
    return cacheEntry.data;
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError *__autoreleasing *)pError
{
    if (! contents) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileWriteUnknownError
                          localizedDescription:CoconutKitLocalizedString(@"No data has been provided", nil)];
        }
        return NO;
    }
    
    // Must fail if the parent directory does not exist
    if (! [self checkParentDirectoryForPath:path error:pError]) {
        return NO;
    }
    
    return [self addObjectAtPath:path withData:contents error:pError];
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError *__autoreleasing *)pError
{
    if (! withIntermediateDirectories) {
        if (! [self checkParentDirectoryForPath:path error:pError]) {
            return NO;
        }
    }
    
    return [self addObjectAtPath:path withData:nil error:pError];
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError
{
    id subitems = [self contentAtPath:path forItems:self.rootItems];
    if (! [subitems isKindOfClass:[NSDictionary class]]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:[NSString stringWithFormat:CoconutKitLocalizedString(@"The directory %@ does not exist", nil), path]];
        }
        return nil;
    }
    
    return [subitems allKeys];
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)pIsDirectory
{
    id subitems = [self contentAtPath:path forItems:self.rootItems];
    if (! subitems) {
        return NO;
    }
    
    if (pIsDirectory) {
        *pIsDirectory = [subitems isKindOfClass:[NSDictionary class]];
    }
    
    return YES;
}

- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError *__autoreleasing *)pError
{
    // Prevent recursive copy
    if ([destinationPath hasPrefix:sourcePath]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileReadInvalidFileNameError
                          localizedDescription:CoconutKitLocalizedString(@"The destination cannot be contained in the source", nil)];
        }
        return NO;
    }
    
    // Get the directory in which the element to copy is located
    id sourceContent = [self contentAtPath:[sourcePath stringByDeletingLastPathComponent] forItems:self.rootItems];
    if (! [sourceContent isKindOfClass:[NSDictionary class]]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"The source file or directory does not exist", nil)];
        }
        return NO;
    }
    
    // Get the destination directory contents
    id destinationContent = [self contentAtPath:[destinationPath stringByDeletingLastPathComponent] forItems:self.rootItems];
    if (! [destinationContent isKindOfClass:[NSDictionary class]]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"The destination directory does not exist", nil)];
        }
        return NO;
    }
    
    return [self copyObjectWithName:[sourcePath lastPathComponent]
                            inItems:sourceContent
                   toObjectWithName:[destinationPath lastPathComponent]
                            inItems:destinationContent
                              error:pError];
}

- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError *__autoreleasing *)pError
{
    // Prevent recursive move
    if ([destinationPath hasPrefix:sourcePath]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileReadInvalidFileNameError
                          localizedDescription:CoconutKitLocalizedString(@"The destination cannot be contained in the source", nil)];
        }
        return NO;
    }
    
    // Get the directory in which the element to move is located
    id sourceContent = [self contentAtPath:[sourcePath stringByDeletingLastPathComponent] forItems:self.rootItems];
    if (! [sourceContent isKindOfClass:[NSDictionary class]]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"The source file or directory does not exist", nil)];
        }
        return NO;
    }
    
    // Get the destination directory contents
    id destinationContent = [self contentAtPath:[destinationPath stringByDeletingLastPathComponent] forItems:self.rootItems];
    if (! [destinationContent isKindOfClass:[NSDictionary class]]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"The destination directory does not exist", nil)];
        }
        return NO;
    }
    
    return  [self moveObjectWithName:[sourcePath lastPathComponent]
                             inItems:sourceContent
                    toObjectWithName:[destinationPath lastPathComponent]
                             inItems:destinationContent
                               error:pError];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError
{
    // Get the directory in which the element to delete is located
    id content = [self contentAtPath:[path stringByDeletingLastPathComponent] forItems:self.rootItems];
    if (! [content isKindOfClass:[NSDictionary class]]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileNoSuchFileError
                          localizedDescription:CoconutKitLocalizedString(@"File or directory not found", nil)];
        }
        return NO;
    }
    
    // Never delete the root, rather delete all its contents
    NSArray *pathComponents = [path pathComponents];
    if ([pathComponents count] == 1 && [[pathComponents firstObject] isEqualToString:@"/"]) {
        for (NSString *name in [content allKeys]) {
            if (! [self removeItemWithName:name inItems:content error:NULL]) {
                HLSLoggerWarn(@"Could not remove %@", name);
            }
        }
        return YES;
    }
    else {
        NSString *name = [path lastPathComponent];
        return [self removeItemWithName:name inItems:content error:pError];
    }
}

#pragma mark NSCacheDelegate protocol implementation

- (void)cache:(NSCache *)cache willEvictObject:(id)object
{
    // Remove the corresponding entry from the rootItems dictionary hierarchy
    HLSInMemoryCacheEntry *cacheEntry = object;
    [cacheEntry.parentItems removeObjectForKey:cacheEntry.name];
}

#pragma mark Notification callbacks

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    [self.cache removeAllObjects];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; rootItems: %@; cache: %@>",
            [self class],
            self,
            self.rootItems,
            self.cache];
}

@end
