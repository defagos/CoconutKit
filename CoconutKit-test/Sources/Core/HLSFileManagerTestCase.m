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
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/file1.txt" error:&error1], data1, nil);
    GHAssertNil(error1, nil);
    
    // File creation, parent directory does not exist. Must fail
    NSError *error11 = nil;
    NSData *data11 = [@"data11" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertFalse([fileManager createFileAtPath:@"/folder1/file11.txt" contents:data11 error:&error11], nil);
    GHAssertNotNil(error11, nil);
    
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
    
    // Folder creation, parent folder does not exist. Must fail
    NSError *error42 = nil;
    NSData *data42 = [@"data42" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertFalse([fileManager createFileAtPath:@"/folder4/file42.txt" contents:data42 error:&error42], nil);
    GHAssertNotNil(error42, nil);
    
    // File creation, no data. Must fail
    NSError *error5 = nil;
    GHAssertFalse([fileManager createFileAtPath:@"/file5.txt" contents:nil error:&error5], nil);
    GHAssertNotNil(error5, nil);
    
    // File which already exists. Must succeed (and replace the data content)
    NSError *error1b = nil;
    NSData *data1b = [@"data1b" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data1b error:&error1b], nil);
    GHAssertNil(error1b, nil);
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/file1.txt" error:&error1b], data1b, nil);
    GHAssertNil(error1b, nil);
    
    // Invalid file path. Must begin with /
    NSError *error6 = nil;
    NSData *data6 = [@"data6" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertFalse([fileManager createFileAtPath:@"file6.txt" contents:data6 error:&error6], nil);
    GHAssertNotNil(error6, nil);
    
    // Invalid folder path. Must begin with /
    NSError *error7 = nil;
    GHAssertFalse([fileManager createDirectoryAtPath:@"folder7" withIntermediateDirectories:YES error:&error7], nil);
    GHAssertNotNil(error7, nil);
    
    // Folder which already exists. Must succeed
    NSError *error2b = nil;
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:&error2b], nil);
    GHAssertNil(error2b, nil);
    
    // Folder paths can end with a / (though weird)
    NSError *error8 = nil;
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder8/" withIntermediateDirectories:YES error:&error8], nil);
    GHAssertNil(error8, nil);
    
    // Folder paths can end with a / (though weirder)
    NSError *error9 = nil;
    NSData *data9 = [@"data9" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file9.txt/" contents:data9 error:&error9], nil);
    GHAssertNil(error9, nil);
}

- (void)testContentsWithFileManager:(HLSFileManager *)fileManager
{
    // Create some files and folders
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder3" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/file31.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/file32.txt" contents:data error:NULL], nil);

    // List files at the root. Must succeed
    NSError *error1 = nil;
    GHAssertEquals([[fileManager contentsOfDirectoryAtPath:@"/" error:&error1] count], 3U, nil);
    GHAssertNil(error1, nil);
    
    // List files in existing non-empty directory. Must succeed
    NSError *error2 = nil;
    GHAssertEquals([[fileManager contentsOfDirectoryAtPath:@"/folder3" error:&error2] count], 2U, nil);
    GHAssertNil(error2, nil);
    
    // List file in existing empty directory. Must succeed and return an empty array
    NSError *error3 = nil;
    NSArray *contents3 = [fileManager contentsOfDirectoryAtPath:@"/folder2" error:&error3];
    GHAssertNotNil(contents3, nil);
    GHAssertEquals([contents3 count], 0U, nil);
    GHAssertNil(error3, nil);
    
    // Invalid path (does not exist). Must fail and return nil
    NSError *error4 = nil;
    GHAssertNil([fileManager contentsOfDirectoryAtPath:@"/invalid/folder" error:&error4], nil);
    GHAssertNotNil(error4, nil);
    
    // Invalid path (not beginning with a /). Must fail and return nil
    NSError *error5 = nil;
    GHAssertNil([fileManager contentsOfDirectoryAtPath:@"invalid" error:&error5], nil);
    GHAssertNotNil(error5, nil);
    
    // Invalid path (corresponds to a file). Must fail and return nil
    NSError *error6 = nil;
    GHAssertNil([fileManager contentsOfDirectoryAtPath:@"/file1.txt" error:&error6], nil);
    GHAssertNotNil(error6, nil);
    
    // Existing files
    BOOL isDirectory7 = YES;
    GHAssertTrue([fileManager fileExistsAtPath:@"/file1.txt" isDirectory:&isDirectory7], nil);
    GHAssertFalse(isDirectory7, nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder3/file31.txt" isDirectory:&isDirectory7], nil);
    GHAssertFalse(isDirectory7, nil);
    
    // Existing directory
    BOOL isDirectory8 = YES;
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder2" isDirectory:&isDirectory8], nil);
    
    // Non-existing file. Must not alter the value of isDirectory
    BOOL isDirectory9 = YES;
    GHAssertFalse([fileManager fileExistsAtPath:@"/invalid.txt" isDirectory:&isDirectory9], nil);
    GHAssertTrue(isDirectory9, nil);
    
    // Non-existing directory. Must not alter the value of isDirectory
    BOOL isDirectory10 = YES;
    GHAssertFalse([fileManager fileExistsAtPath:@"/invalid" isDirectory:&isDirectory10], nil);
    GHAssertTrue(isDirectory10, nil);
    
    // Simple existence tests
    GHAssertTrue([fileManager fileExistsAtPath:@"/file1.txt"], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder2"], nil);
    GHAssertFalse([fileManager fileExistsAtPath:@"/invalid.txt"], nil);
    GHAssertFalse([fileManager fileExistsAtPath:@"/invalid"], nil);
    
    // Paths can end with a / (though weird)
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder2/"], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/file1.txt/"], nil);
    
    // Invalid paths. Must not alter the value of isDirectory
    BOOL isDirectory11 = YES;
    GHAssertFalse([fileManager fileExistsAtPath:@"invalid/path" isDirectory:&isDirectory11], nil);
    GHAssertTrue(isDirectory11, nil);
}

- (void)testStreamsWithFileManager:(HLSFileManager *)fileManager
{

}

@end
