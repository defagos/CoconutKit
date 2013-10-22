//
//  HLSInMemoryFileManagerTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 21.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSInMemoryFileManagerTestCase.h"

@implementation HLSInMemoryFileManagerTestCase

#pragma mark Tests

- (void)testCreation
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testCreationWithFileManager:fileManager];
}

- (void)testContents
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testContentsWithFileManager:fileManager];
}

- (void)testStreams
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    [self testStreamsWithFileManager:fileManager];
}

@end
