//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSInMemoryFileManagerTestCase.h"

@implementation HLSInMemoryFileManagerTestCase

#pragma mark Tests

- (void)testCreationAndRemoval
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testCreationAndRemovalWithFileManager:fileManager];
}

- (void)testContentsAndExistence
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testContentsAndExistenceWithFileManager:fileManager];
}

- (void)testCopy
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testCopyWithFileManager:fileManager];
}

- (void)testMove
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testMoveWithFileManager:fileManager];
}

- (void)testStreams
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testStreamsWithFileManager:fileManager];
}

- (void)testURLs
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testURLsWithFileManager:fileManager];
}

@end
