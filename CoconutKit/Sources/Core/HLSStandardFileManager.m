//
//  HLSStandardFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSStandardFileManager.h"

__attribute__ ((constructor)) static void HLSStandardFileManagerInstall(void)
{
    HLSStandardFileManager *fileManager = [[[HLSStandardFileManager alloc] init] autorelease];
    [HLSFileManager setDefaultManager:fileManager];
}

@implementation HLSStandardFileManager

#pragma mark DMSFileManagerAbstract protocol implementation

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

@end
