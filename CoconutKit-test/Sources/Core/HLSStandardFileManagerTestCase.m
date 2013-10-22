//
//  HLSStandardFileManagerTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 21.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSStandardFileManagerTestCase.h"

@implementation HLSStandardFileManagerTestCase

#pragma mark Class methods

+ (NSString *)rootFolderPath
{
    return [HLSApplicationTemporaryDirectoryPath() stringByAppendingPathComponent:@"fileManagerTests"];
}

#pragma mark Setup and teardown

- (void)setUp
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:rootFolderPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:rootFolderPath error:NULL];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:rootFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
}

#pragma mark Tests

- (void)testCreation
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testCreationWithFileManager:fileManager];
}

- (void)testContents
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testContentsWithFileManager:fileManager];
}

- (void)testStreams
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testStreamsWithFileManager:fileManager];
}

@end
