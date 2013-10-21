//
//  HLSInMemoryFileManagerTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 21.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSInMemoryFileManagerTestCase.h"

@implementation HLSInMemoryFileManagerTestCase

// TODO: Decide if we require / at the beginning of paths
- (void)testCreation
{
    HLSInMemoryFileManager *fileManager = [[HLSInMemoryFileManager alloc] init];
    
    // File creation, parent directory exists. Must succeed
    NSError *error1 = nil;
    NSData *data1 = [@"data1" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data1 error:&error1], nil);
    GHAssertNil(error1, nil);
    
    // Folder creation, parent directory exists. Must succeed
    NSError *error2 = nil;
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:NO error:&error2], nil);
    GHAssertNil(error2, nil);
    
    // Folder creation with intermediate folders. Must succeed
    NSError *error31 = nil;
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder3/folder31" withIntermediateDirectories:YES error:&error31], nil);
    GHAssertNil(error31, nil);
    
    // Folder creation, no intermediate folders, parent folder does not exist. Must fail
    NSError *error41 = nil;
    GHAssertFalse([fileManager createDirectoryAtPath:@"/folder4/folder41" withIntermediateDirectories:NO error:&error41], nil);
    GHAssertNotNil(error41, nil);
    
    // Fole creation, parent folder does not exist. Must fail
    NSError *error42 = nil;
    NSData *data42 = [@"data42" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertFalse([fileManager createFileAtPath:@"/folder4/file41.txt" contents:data42 error:&error42], nil);
    GHAssertNotNil(error42, nil);
    
    // File creation, no data. Must fail
    NSError *error5 = nil;
    GHAssertFalse([fileManager createFileAtPath:@"/file5.txt" contents:nil error:&error5], nil);
    GHAssertNotNil(error5, nil);
    
    // Try to create a file which already exists. Must fail
    NSError *error1b = nil;
    NSData *data1b = [@"data1b" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertFalse([fileManager createFileAtPath:@"/file1.txt" contents:data1b error:&error1b], nil);
    GHAssertNotNil(error1b, nil);
}

// TODO: Add stream support
- (void)testStreams
{

}

@end
