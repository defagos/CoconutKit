//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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

- (void)testCreationAndRemoval
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testCreationAndRemovalWithFileManager:fileManager];
}

- (void)testContentsAndExistence
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testContentsAndExistenceWithFileManager:fileManager];
}

- (void)testCopy
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testCopyWithFileManager:fileManager];
}

- (void)testMove
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testMoveWithFileManager:fileManager];
}

- (void)testStreams
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testStreamsWithFileManager:fileManager];
}

- (void)testURLs
{
    NSString *rootFolderPath = [HLSStandardFileManagerTestCase rootFolderPath];
    HLSStandardFileManager *fileManager = [[HLSStandardFileManager alloc] initWithRootFolderPath:rootFolderPath];
    [self testURLsWithFileManager:fileManager];
}

@end
