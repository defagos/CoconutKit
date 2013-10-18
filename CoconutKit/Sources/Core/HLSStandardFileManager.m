//
//  HLSStandardFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSStandardFileManager.h"

@implementation HLSStandardFileManager

#pragma mark Class methods

+ (HLSStandardFileManager *)defaultManager
{
    static HLSStandardFileManager *s_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[HLSStandardFileManager alloc] init];
    });
    return s_sharedInstance;
}

#pragma mark HLSFileManagerAbstract protocol implementation

- (NSData *)contentsOfFileAtPath:(NSString *)path error:(NSError **)pError
{
    return [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:pError];
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError **)pError
{
    return [contents writeToFile:path options:NSDataWritingAtomic error:pError];
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError **)pError
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:withIntermediateDirectories attributes:nil error:pError];
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)pError
{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:pError];
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)pIsDirectory
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:pIsDirectory];
}

- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{
    return [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:pError];
}

- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{
    return [[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:destinationPath error:pError];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)pError;
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:pError];
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
    
    return [NSInputStream inputStreamWithFileAtPath:path];
}

- (NSOutputStream *)outputStreamToFileAtPath:(NSString *)path append:(BOOL)append
{
    return [NSOutputStream outputStreamToFileAtPath:path append:append];
}

#pragma mark HLSFileManagerURLSupport protocol implementation

- (NSURL *)URLForFileAtPath:(NSString *)path
{
    return [NSURL fileURLWithPath:path];
}

@end
