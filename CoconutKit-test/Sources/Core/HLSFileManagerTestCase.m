//
//  HLSFileManagerTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 21.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSFileManagerTestCase.h"

@implementation HLSFileManagerTestCase

#pragma mark Common test code

- (void)testCreationWithFileManager:(HLSFileManager *)fileManager
{
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
    
    // File creation, no data. Must return NO, but no error
    NSError *error5 = nil;
    GHAssertFalse([fileManager createFileAtPath:@"/file5.txt" contents:nil error:&error5], nil);
    GHAssertNil(error5, nil);
    
    // Try to create a file which already exists. Must fail
    NSError *error1b = nil;
    NSData *data1b = [@"data1b" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertFalse([fileManager createFileAtPath:@"/file1.txt" contents:data1b error:&error1b], nil);
    GHAssertNotNil(error1b, nil);
    
    // Invalid file path. Must begin with /
    NSError *error6 = nil;
    NSData *data6 = [@"data6" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertFalse([fileManager createFileAtPath:@"file6.txt" contents:data6 error:&error6], nil);
    GHAssertNotNil(error6, nil);
    
    // Invalid folder path. Must begin with /
    NSError *error7 = nil;
    GHAssertFalse([fileManager createDirectoryAtPath:@"folder7" withIntermediateDirectories:YES error:&error7], nil);
    GHAssertNotNil(error7, nil);
}

- (void)testStreamsWithFileManager:(HLSFileManager *)fileManager
{

}

@end
