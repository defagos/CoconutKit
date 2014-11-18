//
//  HLSStandardFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSStandardFileManager.h"

#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"

@interface HLSStandardFileManager ()

@property (nonatomic, strong) NSString *rootFolderPath;

@end

@implementation HLSStandardFileManager

#pragma mark Class methods

+ (instancetype)defaultManager
{
    static HLSStandardFileManager *s_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[[self class] alloc] init];
    });
    return s_sharedInstance;
}

#pragma mark Object creation and destruction

- (instancetype)initWithRootFolderPath:(NSString *)rootFolderPath
{
    if (self = [super init]) {
        if (! rootFolderPath) {
            rootFolderPath = @"/";
        }
        
        if (! [rootFolderPath hasPrefix:@"/"]) {
            HLSLoggerError(@"The root folder path must begin with a slash");
            return nil;
        }
        
        // Create the folder if it does not exist
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:rootFolderPath isDirectory:&isDirectory]) {
            if (! isDirectory) {
                HLSLoggerError(@"The path %@ already exists and is not a directory", rootFolderPath);
                return nil;
            }
        }
        else {
            NSError *error = nil;
            if (! [[NSFileManager defaultManager] createDirectoryAtPath:rootFolderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                HLSLoggerError(@"Could not create directory %@. Reason: %@", rootFolderPath, error);
                return nil;
            }
        }
        
        self.rootFolderPath = rootFolderPath;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithRootFolderPath:nil];
}

#pragma mark Helpers

- (NSString *)fullPathForPath:(NSString *)path withError:(NSError *__autoreleasing *)pError
{
    if (! [path hasPrefix:@"/"]) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileReadInvalidFileNameError
                          localizedDescription:CoconutKitLocalizedString(@"Invalid file path", nil)];
        }
        return nil;
    }
    
    return [self.rootFolderPath stringByAppendingPathComponent:path];;
}

#pragma mark HLSFileManagerAbstract protocol implementation

- (NSData *)contentsOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError
{
    NSString *fullPath = [self fullPathForPath:path withError:pError];
    if (! fullPath) {
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:fullPath options:NSDataReadingMappedIfSafe error:pError];
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError *__autoreleasing *)pError
{
    // NSFileManager returns NO but no error when contents == nil
    if (! contents) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileWriteUnknownError
                          localizedDescription:CoconutKitLocalizedString(@"No data has been provided", nil)];
        }
        return NO;
    }
    
    NSString *fullPath = [self fullPathForPath:path withError:pError];
    if (! fullPath) {
        return NO;
    }
    
    // Overwrite existing files, returning YES and no error
    return [contents writeToFile:fullPath options:NSDataWritingAtomic error:pError];
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError *__autoreleasing *)pError
{
    NSString *fullPath = [self fullPathForPath:path withError:pError];
    if (! fullPath) {
        return NO;
    }
    
    // Return YES if the directory already exists
    return [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:withIntermediateDirectories attributes:nil error:pError];
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError
{
    NSString *fullPath = [self fullPathForPath:path withError:pError];
    if (! fullPath) {
        return nil;
    }
    
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:pError];
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)pIsDirectory
{
    NSString *fullPath = [self fullPathForPath:path withError:NULL];
    if (! fullPath) {
        return NO;
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:pIsDirectory];
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
    
    NSString *fullSourcePath = [self fullPathForPath:sourcePath withError:pError];
    if (! fullSourcePath) {
        return NO;
    }
    
    NSString *fullDestinationPath = [self fullPathForPath:destinationPath withError:pError];
    if (! fullDestinationPath) {
        return NO;
    }
    
    return [[NSFileManager defaultManager] copyItemAtPath:fullSourcePath toPath:fullDestinationPath error:pError];
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
    
    NSString *fullSourcePath = [self fullPathForPath:sourcePath withError:pError];
    if (! fullSourcePath) {
        return NO;
    }
    
    NSString *fullDestinationPath = [self fullPathForPath:destinationPath withError:pError];
    if (! fullDestinationPath) {
        return NO;
    }
    
    return [[NSFileManager defaultManager] moveItemAtPath:fullSourcePath toPath:fullDestinationPath error:pError];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError
{
    NSString *fullPath = [self fullPathForPath:path withError:pError];
    if (! fullPath) {
        return NO;
    }

    // Never delete the root, rather delete all its contents
    NSArray *pathComponents = [path pathComponents];
    if ([pathComponents count] == 1 && [[pathComponents firstObject] isEqualToString:@"/"]) {
        NSArray *contents = [self contentsOfDirectoryAtPath:@"/" error:NULL];
        for (NSString *content in contents) {
            NSString *contentPath = [path stringByAppendingPathComponent:content];
            if (! [self removeItemAtPath:contentPath error:NULL]) {
                HLSLoggerWarn(@"Could not remove %@", content);
            }
        }
        return YES;
    }
    else {
        return [[NSFileManager defaultManager] removeItemAtPath:fullPath error:pError];
    }
}

#pragma mark HLSFileManagerStreamSupport protocol implementation

- (NSInputStream *)inputStreamWithFileAtPath:(NSString *)path
{
    // If the path is invalid, NSInputStream returns a stream object which fails to open, not nil
    BOOL isDirectory = NO;
    if (! [self fileExistsAtPath:path isDirectory:&isDirectory]) {
        return nil;
    }
    
    if (isDirectory) {
        return nil;
    }
    
    NSString *fullPath = [self fullPathForPath:path withError:NULL];
    if (! fullPath) {
        return nil;
    }
    
    return [NSInputStream inputStreamWithFileAtPath:fullPath];
}

- (NSOutputStream *)outputStreamToFileAtPath:(NSString *)path append:(BOOL)append
{
    BOOL isDirectory = NO;
    if ([self fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
        return nil;
    }
    
    NSString *fullPath = [self fullPathForPath:path withError:NULL];
    if (! fullPath) {
        return nil;
    }
    
    return [NSOutputStream outputStreamToFileAtPath:fullPath append:append];
}

#pragma mark HLSFileManagerURLSupport protocol implementation

- (NSURL *)URLForFileAtPath:(NSString *)path
{
    if (! [self fileExistsAtPath:path]) {
        return nil;
    }
    
    NSString *fullPath = [self fullPathForPath:path withError:NULL];
    if (! fullPath) {
        return nil;
    }
    
    return [NSURL fileURLWithPath:fullPath];
}

@end
