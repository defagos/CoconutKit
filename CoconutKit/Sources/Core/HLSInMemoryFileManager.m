//
//  HLSInMemoryFileManager.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 18.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSInMemoryFileManager.h"

#import "HLSError.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSString+HLSExtensions.h"

@interface HLSInMemoryFileManager ()

@property (nonatomic, strong) NSMutableDictionary *rootItems;           // Stores the directory / file hierarchy
@property (nonatomic, strong) NSCache *cache;                           // Store data

@end

@implementation HLSInMemoryFileManager

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.rootItems = [NSMutableDictionary dictionary];
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark Content management

/**
 * We use dictionaries to store directory structure and file names. A dictionary key is the name of a file or of a folder.
 * For folders, the corresponding value is a dictionary (which might be empty if the directory is empty). For files, the
 * value is a unique string identifier, pointing at the corresponding NSCache data entry
 *
 * Intermediate directories are created if they do not exist. If data is nil, a folder is added, otherwise a file
 */
- (void)addObjectAtPath:(NSString *)path withData:(NSData *)data
{
    [self addObjectAtPath:path toItems:self.rootItems withData:data];
}

- (void)addObjectAtPath:(NSString *)path toItems:(NSMutableDictionary *)items withData:(NSData *)data
{
    NSArray *pathComponents = [path pathComponents];
    if ([pathComponents count] == 0) {
        return;
    }
    
    if ([pathComponents count] == 1) {
        NSString *objectName = [pathComponents firstObject];
        
        // File
        if (data) {
            NSString *UUID = HLSUUID();
            [items setObject:UUID forKey:objectName];
            [self.cache setObject:data forKey:UUID];
        }
        // Folder
        else {
            [items setObject:[NSMutableDictionary dictionary] forKey:objectName];
        }
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
        [self addObjectAtPath:subpath toItems:subitems withData:data];
    }
}

/**
 * Return either a dictionary (folder) or a data string identifier (file)
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

- (BOOL)removeItemWithName:(NSString *)name inItems:(NSMutableDictionary *)items error:(NSError **)pError
{
    id content = [items objectForKey:name];
    if (! content) {
        if (pError) {
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
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

- (BOOL)checkParentDirectoryForPath:(NSString *)path error:(NSError **)pError
{
    BOOL isDirectory = NO;
    NSString *parentPath = [path stringByDeletingLastPathComponent];
    if (! [self fileExistsAtPath:parentPath isDirectory:&isDirectory] || ! isDirectory) {
        if (pError) {
            NSString *errorMessage = [NSString stringWithFormat:@"The directory %@ does not exist", parentPath];
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileWriteUnknownError
                           localizedDescription:CoconutKitLocalizedString(errorMessage, nil)];
        }
        return NO;
    }
    return YES;
}

#pragma mark HLSFileManagerAbstract protocol implementation

- (NSData *)contentsOfFileAtPath:(NSString *)path error:(NSError **)pError
{
    id content = [self contentAtPath:path forItems:self.rootItems];
    if (! content || ! [content isKindOfClass:[NSString class]]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileNoSuchFileError
                           localizedDescription:CoconutKitLocalizedString(@"File not found", nil)];
        }
        return nil;        
    }
    
    return [self.cache objectForKey:content];
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError **)pError
{
    // Must fail if the parent directory does not exist
    if (! [self checkParentDirectoryForPath:path error:pError]) {
        return NO;
    }
    
    [self addObjectAtPath:path withData:contents];
    return YES;
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError **)pError
{
    if (! withIntermediateDirectories) {
        if (! [self checkParentDirectoryForPath:path error:pError]) {
            return NO;
        }
    }
    
    [self addObjectAtPath:path withData:nil];
    return YES;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)pError
{
    id subitems = [self contentAtPath:path forItems:self.rootItems];
    if (! [subitems isKindOfClass:[NSDictionary dictionary]]) {
        if (pError) {
            NSString *errorMessage = [NSString stringWithFormat:@"The directory %@ does not exist", path];
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileWriteUnknownError
                           localizedDescription:CoconutKitLocalizedString(errorMessage, nil)];
        }
        return nil;
    }
    
    return [subitems allKeys];
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)pIsDirectory
{
    id subitems = [self contentAtPath:path forItems:self.rootItems];
    if (pIsDirectory) {
        *pIsDirectory = [subitems isKindOfClass:[NSDictionary class]];
    }
    return subitems != nil;
}

- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{
    id sourceContent = [self contentAtPath:sourcePath forItems:self.rootItems];
    if (! sourceContent) {
        if (pError) {
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileNoSuchFileError
                           localizedDescription:CoconutKitLocalizedString(@"File not found", nil)];
        }
        return NO;
    }
    
    // Folder
    if ([sourceContent isKindOfClass:[NSDictionary class]]) {
        [self addObjectAtPath:destinationPath withData:nil];
    }
    // File
    else {
        NSData *data = [self.cache objectForKey:sourceContent];
        [self addObjectAtPath:destinationPath withData:data];
    }
    
    return YES;
}

- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{
    if (! [self copyItemAtPath:sourcePath toPath:destinationPath error:pError]) {
        return NO;
    }
    
    return [self removeItemAtPath:sourcePath error:pError];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)pError
{
    NSString *name = [path lastPathComponent];
    id content = [self contentAtPath:[path stringByDeletingLastPathComponent] forItems:self.rootItems];
    if (! [content isKindOfClass:[NSDictionary class]]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileNoSuchFileError
                           localizedDescription:CoconutKitLocalizedString(@"File or directory not found", nil)];
        }
        return NO;
    }
    
    return [self removeItemWithName:name inItems:content error:pError];
}

#pragma mark NSCacheDelegate protocol implementation

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    // TODO: Lookup object and remove entry in filesystem dict
}

@end
