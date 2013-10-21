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

@interface HLSInMemoryFileManager ()

@property (nonatomic, strong) NSMutableDictionary *rootItems;
@property (nonatomic, strong) NSCache *cache;

@end

@implementation HLSInMemoryFileManager

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.cache = [[NSCache alloc] init];
        self.rootItems = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark Directory management

/**
 * We use dictionaries to store directory structure and file names. A dictionary key is the name of a file or of a folder.
 * For folders, the corresponding value is a dictionary (which might be empty if the directory is empty). For files, the
 * value is [NSNull null]
 *
 * Intermediate directories are created if they do not exist
 */
- (void)addObjectAtPath:(NSString *)path isDirectory:(BOOL)isDirectory
{
    [HLSInMemoryFileManager addObjectAtPath:path toItems:self.rootItems isDirectory:isDirectory];
}

+ (void)addObjectAtPath:(NSString *)path toItems:(NSMutableDictionary *)items isDirectory:(BOOL)isDirectory
{
    NSArray *pathComponents = [path pathComponents];
    if ([pathComponents count] == 0) {
        return;
    }
    
    if ([pathComponents count] == 1) {
        NSString *objectName = [pathComponents firstObject];
        [items setObject:(isDirectory ? [NSMutableDictionary dictionary] : [NSNull null])
                     forKey:objectName];
    }
    else {
        NSString *firstPathComponent = [pathComponents firstObject];
        
        // Create intermediate directories
        NSMutableDictionary *subitems = [items objectForKey:firstPathComponent];
        if (! subitems) {
            subitems = [NSMutableDictionary dictionary];
            [items setObject:subitems forKey:firstPathComponent];
        }
        
        NSArray *subpathComponents = [pathComponents subarrayWithRange:NSMakeRange(1, [pathComponents count] - 1)];
        NSString *subpath = [NSString pathWithComponents:subpathComponents];
        [self addObjectAtPath:subpath toItems:subitems isDirectory:isDirectory];
    }
}

/**
 * Return either a dictionary (folder) or NSNull (files)
 */
+ (id)subitemsAtPath:(NSString *)path forItems:(NSDictionary *)items
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
        return [self subitemsAtPath:subpath forItems:subitems];
    }  
}

#if 0
+ (BOOL)removeItemAtPath:(NSString *)path forItems:(NSDictionary *)items cache:(NSCache *)cache error:(NSError **)pError
{
    // TODO: Must also work when called at the top of the hierarchy
    NSString *parentPath = [path stringByDeletingLastPathComponent];
    id parentItems = [self subitemsAtPath:parentPath forItems:items];
    if (! [parentItems isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    NSString *lastPathComponent = [path lastPathComponent];
    [parentItems removeObjectForKey:lastPathComponent];
    
    // Remove associated data (if any)
    [cache removeObjectForKey:path];
    
}
#endif

- (BOOL)removeItemWithName:(NSString *)name inItems:(NSMutableDictionary *)items error:(NSError **)pError
{
    if (! [items objectForKey:name]) {
        if (pError) {
            // TODO: Does not exist
        }
        return NO;
    }
    
    [items removeObjectForKey:name];
    
    // TODO: Problem: The path is unknown! => instead of NSNull, store NSString = unique generated id (not from path hash). More
    //       robust when we move around stuff, since the id does not change
//    [self.cache removeObjectForKey:name];
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
    NSData *data = [self.cache objectForKey:path];
    if (! data) {
        if (pError) {
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileNoSuchFileError
                           localizedDescription:CoconutKitLocalizedString(@"Not found", nil)];
        }
        return nil;
    }
    return data;
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError **)pError
{
    // Must fail if the parent directory does not exist
    if (! [self checkParentDirectoryForPath:path error:pError]) {
        return NO;
    }
    
    [self addObjectAtPath:path isDirectory:NO];
    [self.cache setObject:contents forKey:path];
    return YES;
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError **)pError
{
    if (! withIntermediateDirectories) {
        if (! [self checkParentDirectoryForPath:path error:pError]) {
            return NO;
        }
    }
    
    [self addObjectAtPath:path isDirectory:YES];    
    return YES;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)pError
{
    id subitems = [HLSInMemoryFileManager subitemsAtPath:path forItems:self.rootItems];
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
    id subitems = [HLSInMemoryFileManager subitemsAtPath:path forItems:self.rootItems];
    if (pIsDirectory) {
        *pIsDirectory = [subitems isKindOfClass:[NSDictionary class]];
    }
    return subitems != nil;
}

- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{

}

- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{

}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)pError
{

}

#pragma mark NSCacheDelegate protocol implementation

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{

}

@end
