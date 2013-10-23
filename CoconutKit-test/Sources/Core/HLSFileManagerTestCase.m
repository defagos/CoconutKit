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

- (void)testCreationAndRemovalWithFileManager:(HLSFileManager *)fileManager
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
    
    // Creation of the root folder. No-op, but still a success
    NSError *error10 = nil;
    GHAssertTrue([fileManager createDirectoryAtPath:@"/" withIntermediateDirectories:YES error:&error10], nil);
    GHAssertNil(error10, nil);
    
    // Remove existing file. Must succeed
    NSError *remError1 = nil;
    GHAssertTrue([fileManager removeItemAtPath:@"/file1.txt" error:&remError1], nil);
    GHAssertNil(remError1, nil);
    GHAssertFalse([fileManager fileExistsAtPath:@"/file1.txt"], nil);
    
    // Remove existing directory. Must succeed
    NSError *remError2 = nil;
    GHAssertTrue([fileManager removeItemAtPath:@"/folder2" error:&remError2], nil);
    GHAssertNil(remError2, nil);
    GHAssertFalse([fileManager fileExistsAtPath:@"/folder2"], nil);
    
    // Remove non-existing file. Must fail and return an error
    NSError *remError3 = nil;
    GHAssertFalse([fileManager removeItemAtPath:@"/invalid.txt" error:&remError3], nil);
    GHAssertNotNil(remError3, nil);
    
    // Remove /. Remove all files, but do not delete the root itself
    NSError *remError4 = nil;
    GHAssertTrue([fileManager removeItemAtPath:@"/" error:&remError4], nil);
    GHAssertNil(remError4, nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/"], nil);
    GHAssertEquals([[fileManager contentsOfDirectoryAtPath:@"/" error:NULL] count], 0U, nil);
}

- (void)testContentsAndExistenceWithFileManager:(HLSFileManager *)fileManager
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
    
    // Existence of the root folder
    BOOL isDirectory12 = NO;
    GHAssertTrue([fileManager fileExistsAtPath:@"/" isDirectory:&isDirectory12], nil);
    GHAssertTrue(isDirectory12, nil);
}

- (void)testCopyWithFileManager:(HLSFileManager *)fileManager
{
    // Create some files and folders
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder3" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/file31.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/file32.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder3/folder33" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/folder33/file331.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/copy" withIntermediateDirectories:YES error:NULL], nil);
    
    // File copy to an existing folder. Must succeed
    NSError *error1 = nil;
    GHAssertTrue([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/copy/file1.txt" error:&error1], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/file1.txt"], nil);
    GHAssertNil(error1, nil);
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/copy/file1.txt" error:&error1], data, nil);
    GHAssertNil(error1, nil);
    
    // File copy to a non-existing folder. Must fail
    NSError *error2 = nil;
    GHAssertFalse([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/invalid/file1.txt" error:&error2], nil);
    GHAssertNotNil(error2, nil);
    
    // File copy onto an existing file. Must fail
    NSError *error3 = nil;
    GHAssertFalse([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/copy/file1.txt" error:&error3], nil);
    GHAssertNotNil(error3, nil);
    
    // File copy onto an existing folder. Must fail
    NSError *error4 = nil;
    GHAssertFalse([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/copy" error:&error4], nil);
    GHAssertNotNil(error4, nil);
    
    // Folder copy to an existing folder. Must succceed and copy recursively
    NSError *error5 = nil;
    GHAssertTrue([fileManager copyItemAtPath:@"/folder3" toPath:@"/copy/folder3" error:&error5], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder3"], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder3/file31.txt"], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder3/folder33/file331.txt"], nil);
    GHAssertNil(error5, nil);
    GHAssertEquals([[fileManager contentsOfDirectoryAtPath:@"/copy/folder3" error:&error5] count], 3U, nil);
    GHAssertNil(error5, nil);
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/copy/folder3/file31.txt" error:&error5], data, nil);
    GHAssertNil(error5, nil);
    GHAssertEquals([[fileManager contentsOfDirectoryAtPath:@"/copy/folder3/folder33" error:&error5] count], 1U, nil);
    GHAssertNil(error5, nil);
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/copy/folder3/folder33/file331.txt" error:&error5], data, nil);
    GHAssertNil(error5, nil);
    
    // Folder copy to a non-existing folder. Must fail
    NSError *error6 = nil;
    GHAssertFalse([fileManager copyItemAtPath:@"/folder3" toPath:@"/invalid/folder3" error:&error6], nil);
    GHAssertNotNil(error6, nil);
    
    // Folder copy onto an existing folder. Must fail
    NSError *error7 = nil;
    GHAssertFalse([fileManager copyItemAtPath:@"/folder3" toPath:@"/copy/folder3" error:&error7], nil);
    GHAssertNotNil(error7, nil);
    
    // Folder copy onto an existing file. Must fail
    NSError *error8 = nil;
    GHAssertFalse([fileManager copyItemAtPath:@"/folder3" toPath:@"/copy/file1.txt" error:&error8], nil);
    GHAssertNotNil(error8, nil);
    
    // Missing copy source file. Must fail
    NSError *error9 = nil;
    GHAssertFalse([fileManager copyItemAtPath:@"/invalid.txt" toPath:@"/copy/invalid.txt" error:&error9], nil);
    GHAssertNotNil(error9, nil);
    
    
    // TODO: Add tests for the following cases:
    //   - copy to the same directory, same name -> what happens? (see with NSFileManager-based implementation)
    //   - copy to a subdirectory of itself -> what happens? (see with NSFileManager-based implementation)
    //   - delete original -> show that copy data is still accessible (i.e. not shared by mistake)
}

- (void)testMoveWithFileManager:(HLSFileManager *)fileManager
{
    // Create some files and folders
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/file4.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder3" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/file31.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/file32.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder3/folder33" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder3/folder33/file331.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/move" withIntermediateDirectories:YES error:NULL], nil);
    
    // File move to an existing folder. Must succeed
    NSError *error1 = nil;
    GHAssertTrue([fileManager moveItemAtPath:@"/file1.txt" toPath:@"/move/file1.txt" error:&error1], nil);
    GHAssertFalse([fileManager fileExistsAtPath:@"/file1.txt"], nil);
    GHAssertNil(error1, nil);
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/move/file1.txt" error:&error1], data, nil);
    GHAssertNil(error1, nil);
    
    // File move to a non-existing folder. Must fail
    NSError *error2 = nil;
    GHAssertFalse([fileManager moveItemAtPath:@"/file4.txt" toPath:@"/invalid/file4.txt" error:&error2], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/file4.txt"], nil);
    GHAssertNotNil(error2, nil);
    
    // File move onto an existing file. Must fail
    NSError *error3 = nil;
    GHAssertFalse([fileManager moveItemAtPath:@"/file4.txt" toPath:@"/move/file1.txt" error:&error3], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/file4.txt"], nil);
    GHAssertNotNil(error3, nil);
    
    // File move onto an existing folder. Must fail
    NSError *error4 = nil;
    GHAssertFalse([fileManager moveItemAtPath:@"/file4.txt" toPath:@"/move" error:&error4], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/file4.txt"], nil);
    GHAssertNotNil(error4, nil);
    
    // Folder move to an existing folder. Must succceed and move recursively
    NSError *error5 = nil;
    GHAssertTrue([fileManager moveItemAtPath:@"/folder3" toPath:@"/move/folder3" error:&error5], nil);
    GHAssertFalse([fileManager fileExistsAtPath:@"/folder3"], nil);
    GHAssertNil(error5, nil);
    GHAssertEquals([[fileManager contentsOfDirectoryAtPath:@"/move/folder3" error:&error5] count], 3U, nil);
    GHAssertNil(error5, nil);
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/move/folder3/file31.txt" error:&error5], data, nil);
    GHAssertNil(error5, nil);
    GHAssertEquals([[fileManager contentsOfDirectoryAtPath:@"/move/folder3/folder33" error:&error5] count], 1U, nil);
    GHAssertNil(error5, nil);
    GHAssertEqualObjects([fileManager contentsOfFileAtPath:@"/move/folder3/folder33/file331.txt" error:&error5], data, nil);
    GHAssertNil(error5, nil);
    
    // Folder move to a non-existing folder. Must fail
    NSError *error6 = nil;
    GHAssertFalse([fileManager moveItemAtPath:@"/folder2" toPath:@"/invalid/folder2" error:&error6], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder2"], nil);
    GHAssertNotNil(error6, nil);
    
    // Folder move onto an existing folder. Must fail
    NSError *error7 = nil;
    GHAssertFalse([fileManager moveItemAtPath:@"/folder2" toPath:@"/move/folder3" error:&error7], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder2"], nil);
    GHAssertNotNil(error7, nil);
    
    // Folder move onto an existing file. Must fail
    NSError *error8 = nil;
    GHAssertFalse([fileManager moveItemAtPath:@"/folder2" toPath:@"/move/file1.txt" error:&error8], nil);
    GHAssertTrue([fileManager fileExistsAtPath:@"/folder2"], nil);
    GHAssertNotNil(error8, nil);
    
    // Missing move source file. Must fail
    NSError *error9 = nil;
    GHAssertFalse([fileManager moveItemAtPath:@"/invalid.txt" toPath:@"/move/invalid.txt" error:&error9], nil);
    GHAssertNotNil(error9, nil);
    
    // TODO: Add tests for the following cases:
    //   - move to the same directory, same name (i.e. does not move) -> what happens? (see with NSFileManager-based implementation)
    //   - move to a subdirectory of itself -> what happens? (see with NSFileManager-based implementation)
}

- (void)testStreamsWithFileManager:(HLSFileManager *)fileManager
{
    // Create test file and folder
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL], nil);
    
    // Input stream with existing file. Must succeeed
    NSInputStream *inputStream1 = [fileManager inputStreamWithFileAtPath:@"/file1.txt"];
    GHAssertNotNil(inputStream1, nil);
    NSOutputStream *outputStream1 = [NSOutputStream outputStreamToMemory];
    GHAssertTrue([inputStream1 writeToOutputStream:outputStream1 error:NULL], nil);
    GHAssertEqualObjects([outputStream1 propertyForKey:NSStreamDataWrittenToMemoryStreamKey], data, nil);
    
    // Input stream with non-existing file. Must fail
    GHAssertNil([fileManager inputStreamWithFileAtPath:@"/invalid.txt"], nil);
    
    // Input stream with folder. Must fail
    GHAssertNil([fileManager inputStreamWithFileAtPath:@"/folder2"], nil);
    
    // Ouput stream to new file. Must succeed
    NSOutputStream *outputStream2 = [fileManager outputStreamToFileAtPath:@"/file2.txt" append:NO];
    GHAssertNotNil(outputStream2, nil);
    NSData *data2 = [@"Hello" dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream *inputStream2 = [NSInputStream inputStreamWithData:data2];
    GHAssertTrue([inputStream2 writeToOutputStream:outputStream2 error:NULL], nil);
    NSData *outData2 = [fileManager contentsOfFileAtPath:@"/file2.txt" error:NULL];
    GHAssertEqualObjects(data2, outData2, nil);
    
    // Output stream to existing file (and append). Must succeed
    NSOutputStream *outputStream3 = [fileManager outputStreamToFileAtPath:@"/file2.txt" append:YES];
    GHAssertNotNil(outputStream3, nil);
    NSInputStream *inputStream3 = [NSInputStream inputStreamWithData:[@", World!" dataUsingEncoding:NSUTF8StringEncoding]];
    GHAssertTrue([inputStream3 writeToOutputStream:outputStream3 error:NULL], nil);
    NSData *outData3 = [fileManager contentsOfFileAtPath:@"/file2.txt" error:NULL];
    GHAssertEqualObjects([@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding], outData3, nil);
    
    // Output stream to existing folder. Must fail
    GHAssertNil([fileManager outputStreamToFileAtPath:@"/folder2" append:NO], nil);
}

- (void)testURLsWithFileManager:(HLSFileManager *)fileManager
{
    // Create test file and folder
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL], nil);
    GHAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL], nil);
    GHAssertTrue([fileManager createFileAtPath:@"/folder2/file21.txt" contents:data error:NULL], nil);
    
    // URL to existing file
    NSURL *URL1 = [fileManager URLForFileAtPath:@"/file1.txt"];
    GHAssertNotNil(URL1, nil);
    GHAssertEqualObjects([NSData dataWithContentsOfURL:URL1], data, nil);
    
    // URLs to existing folders
    GHAssertNotNil([fileManager URLForFileAtPath:@"/folder2"], nil);
    GHAssertNotNil([fileManager URLForFileAtPath:@"/"], nil);
    
    // URLs to a non-existing files
    GHAssertNil([fileManager URLForFileAtPath:@"/invalid"], nil);
    GHAssertNil([fileManager URLForFileAtPath:@"invalid"], nil);
}

@end
