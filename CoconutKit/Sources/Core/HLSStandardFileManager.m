//
//  HLSStandardFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSStandardFileManager.h"

#import "HLSError.h"
#import "HLSLogger.h"
#import "NSBundle+HLSExtensions.h"

@interface HLSStandardFileManager ()

@property (nonatomic, strong) NSString *rootFolderPath;

@end

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

#pragma mark Object creation and destruction

- (id)initWithRootFolderPath:(NSString *)rootFolderPath
{
    if (self = [super init]) {
        if (! rootFolderPath) {
            rootFolderPath = @"/";
        }
        
        if (! [rootFolderPath hasPrefix:@"/"]) {
            HLSLoggerError(@"The root folder path must begin with a slash");
            return nil;
        }
        
        self.rootFolderPath = rootFolderPath;
    }
    return self;
}

- (id)init
{
    return [self initWithRootFolderPath:nil];
}

#pragma mark HLSFileManagerAbstract protocol implementation

- (NSData *)contentsOfFileAtPath:(NSString *)path error:(NSError **)pError
{
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [NSData dataWithContentsOfFile:fullPath options:NSDataReadingMappedIfSafe error:pError];
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError **)pError
{
    // NSFileManager returns NO but no error when contents == nil
    if (! contents) {
        if (pError) {
            *pError = [HLSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileWriteUnknownError
                           localizedDescription:CoconutKitLocalizedString(@"No data has been provided", nil)];
        }
        return NO;
    }
    
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [contents writeToFile:fullPath options:NSDataWritingAtomic error:pError];
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError **)pError
{
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:withIntermediateDirectories attributes:nil error:pError];
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)pError
{
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:pError];
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)pIsDirectory
{
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:pIsDirectory];
}

- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{
    NSString *fullSourcePath = [self.rootFolderPath stringByAppendingPathComponent:sourcePath];
    NSString *fullDestinationPath = [self.rootFolderPath stringByAppendingPathComponent:destinationPath];
    return [[NSFileManager defaultManager] copyItemAtPath:fullSourcePath toPath:fullDestinationPath error:pError];
}

- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError
{
    NSString *fullSourcePath = [self.rootFolderPath stringByAppendingPathComponent:sourcePath];
    NSString *fullDestinationPath = [self.rootFolderPath stringByAppendingPathComponent:destinationPath];
    return [[NSFileManager defaultManager] moveItemAtPath:fullSourcePath toPath:fullDestinationPath error:pError];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)pError;
{
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [[NSFileManager defaultManager] removeItemAtPath:fullPath error:pError];
}

#pragma mark HLSFileManagerStreamSupport protocol implementation

- (NSInputStream *)inputStreamWithFileAtPath:(NSString *)path
{
    // If the path is invalid, NSInputStream returns a stream object which fails to open, not nil
    BOOL isDirectory = NO;
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    if (! [self fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
        return nil;
    }
    
    if (isDirectory) {
        return nil;
    }
    
    return [NSInputStream inputStreamWithFileAtPath:fullPath];
}

- (NSOutputStream *)outputStreamToFileAtPath:(NSString *)path append:(BOOL)append
{
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [NSOutputStream outputStreamToFileAtPath:fullPath append:append];
}

#pragma mark HLSFileManagerURLSupport protocol implementation

- (NSURL *)URLForFileAtPath:(NSString *)path
{
    NSString *fullPath = [self.rootFolderPath stringByAppendingPathComponent:path];
    return [NSURL fileURLWithPath:fullPath];
}

@end
