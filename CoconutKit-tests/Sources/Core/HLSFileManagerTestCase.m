//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSFileManagerTestCase.h"

@implementation HLSFileManagerTestCase

#pragma mark Common test code

- (void)testCreationAndRemovalWithFileManager:(HLSFileManager *)fileManager
{
    // File creation, parent directory exists. Must succeed
    NSError *error1 = nil;
    NSData *data1 = [@"data1" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data1 error:&error1]);
    XCTAssertNil(error1);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/file1.txt" error:&error1], data1);
    XCTAssertNil(error1);
    
    // File creation, parent directory does not exist. Must fail
    NSError *error11 = nil;
    NSData *data11 = [@"data11" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertFalse([fileManager createFileAtPath:@"/folder1/file11.txt" contents:data11 error:&error11]);
    XCTAssertNotNil(error11);
    
    // Folder creation, parent directory exists. Must succeed
    NSError *error2 = nil;
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:NO error:&error2]);
    XCTAssertNil(error2);
    
    // Folder creation with intermediate folders. Must succeed
    NSError *error31 = nil;
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder3/folder31" withIntermediateDirectories:YES error:&error31]);
    XCTAssertNil(error31);
    
    // Folder creation, no intermediate folders, parent folder does not exist. Must fail
    NSError *error41 = nil;
    XCTAssertFalse([fileManager createDirectoryAtPath:@"/folder4/folder41" withIntermediateDirectories:NO error:&error41]);
    XCTAssertNotNil(error41);
    
    // Folder creation, parent folder does not exist. Must fail
    NSError *error42 = nil;
    NSData *data42 = [@"data42" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertFalse([fileManager createFileAtPath:@"/folder4/file42.txt" contents:data42 error:&error42]);
    XCTAssertNotNil(error42);
    
    // File creation, no data. Must fail
    NSError *error5 = nil;
    XCTAssertFalse([fileManager createFileAtPath:@"/file5.txt" contents:nil error:&error5]);
    XCTAssertNotNil(error5);
    
    // File which already exists. Must succeed (and replace the data content)
    NSError *error1b = nil;
    NSData *data1b = [@"data1b" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data1b error:&error1b]);
    XCTAssertNil(error1b);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/file1.txt" error:&error1b], data1b);
    XCTAssertNil(error1b);
    
    // Invalid file path. Must begin with /
    NSError *error6 = nil;
    NSData *data6 = [@"data6" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertFalse([fileManager createFileAtPath:@"file6.txt" contents:data6 error:&error6]);
    XCTAssertNotNil(error6);
    
    // Invalid folder path. Must begin with /
    NSError *error7 = nil;
    XCTAssertFalse([fileManager createDirectoryAtPath:@"folder7" withIntermediateDirectories:YES error:&error7]);
    XCTAssertNotNil(error7);
    
    // Folder which already exists. Must succeed
    NSError *error2b = nil;
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:&error2b]);
    XCTAssertNil(error2b);
    
    // Folder paths can end with a / (though weird)
    NSError *error8 = nil;
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder8/" withIntermediateDirectories:YES error:&error8]);
    XCTAssertNil(error8);
    
    // Folder paths can end with a / (though weirder)
    NSError *error9 = nil;
    NSData *data9 = [@"data9" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file9.txt/" contents:data9 error:&error9]);
    XCTAssertNil(error9);
    
    // Creation of the root folder. No-op, but still a success
    NSError *error10 = nil;
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/" withIntermediateDirectories:YES error:&error10]);
    XCTAssertNil(error10);
    
    // Remove existing file. Must succeed
    NSError *remError1 = nil;
    XCTAssertTrue([fileManager removeItemAtPath:@"/file1.txt" error:&remError1]);
    XCTAssertNil(remError1);
    XCTAssertFalse([fileManager fileExistsAtPath:@"/file1.txt"]);
    
    // Remove existing directory. Must succeed
    NSError *remError2 = nil;
    XCTAssertTrue([fileManager removeItemAtPath:@"/folder2" error:&remError2]);
    XCTAssertNil(remError2);
    XCTAssertFalse([fileManager fileExistsAtPath:@"/folder2"]);
    
    // Remove non-existing file. Must fail and return an error
    NSError *remError3 = nil;
    XCTAssertFalse([fileManager removeItemAtPath:@"/invalid.txt" error:&remError3]);
    XCTAssertNotNil(remError3);
    
    // Remove /. Remove all files, but do not delete the root itself
    NSError *remError4 = nil;
    XCTAssertTrue([fileManager removeItemAtPath:@"/" error:&remError4]);
    XCTAssertNil(remError4);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/"]);
    XCTAssertEqual([[fileManager contentsOfDirectoryAtPath:@"/" error:NULL] count], (NSUInteger)0);
}

- (void)testContentsAndExistenceWithFileManager:(HLSFileManager *)fileManager
{
    // Create some files and folders
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder3" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/file31.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/file32.txt" contents:data error:NULL]);

    // List files at the root. Must succeed
    NSError *error1 = nil;
    XCTAssertEqual([[fileManager contentsOfDirectoryAtPath:@"/" error:&error1] count], (NSUInteger)3);
    XCTAssertNil(error1);
    
    // List files in existing non-empty directory. Must succeed
    NSError *error2 = nil;
    XCTAssertEqual([[fileManager contentsOfDirectoryAtPath:@"/folder3" error:&error2] count], (NSUInteger)2);
    XCTAssertNil(error2);
    
    // List file in existing empty directory. Must succeed and return an empty array
    NSError *error3 = nil;
    NSArray *contents3 = [fileManager contentsOfDirectoryAtPath:@"/folder2" error:&error3];
    XCTAssertNotNil(contents3);
    XCTAssertEqual([contents3 count], (NSUInteger)0);
    XCTAssertNil(error3);
    
    // Invalid path (does not exist). Must fail and return nil
    NSError *error4 = nil;
    XCTAssertNil([fileManager contentsOfDirectoryAtPath:@"/invalid/folder" error:&error4]);
    XCTAssertNotNil(error4);
    
    // Invalid path (not beginning with a /). Must fail and return nil
    NSError *error5 = nil;
    XCTAssertNil([fileManager contentsOfDirectoryAtPath:@"invalid" error:&error5]);
    XCTAssertNotNil(error5);
    
    // Invalid path (corresponds to a file). Must fail and return nil
    NSError *error6 = nil;
    XCTAssertNil([fileManager contentsOfDirectoryAtPath:@"/file1.txt" error:&error6]);
    XCTAssertNotNil(error6);
    
    // Existing files
    BOOL isDirectory7 = YES;
    XCTAssertTrue([fileManager fileExistsAtPath:@"/file1.txt" isDirectory:&isDirectory7]);
    XCTAssertFalse(isDirectory7);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder3/file31.txt" isDirectory:&isDirectory7]);
    XCTAssertFalse(isDirectory7);
    
    // Existing directory
    BOOL isDirectory8 = YES;
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder2" isDirectory:&isDirectory8]);
    
    // Non-existing file. Must not alter the value of isDirectory
    BOOL isDirectory9 = YES;
    XCTAssertFalse([fileManager fileExistsAtPath:@"/invalid.txt" isDirectory:&isDirectory9]);
    XCTAssertTrue(isDirectory9);
    
    // Non-existing directory. Must not alter the value of isDirectory
    BOOL isDirectory10 = YES;
    XCTAssertFalse([fileManager fileExistsAtPath:@"/invalid" isDirectory:&isDirectory10]);
    XCTAssertTrue(isDirectory10);
    
    // Simple existence tests
    XCTAssertTrue([fileManager fileExistsAtPath:@"/file1.txt"]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder2"]);
    XCTAssertFalse([fileManager fileExistsAtPath:@"/invalid.txt"]);
    XCTAssertFalse([fileManager fileExistsAtPath:@"/invalid"]);
    
    // Paths can end with a / (though weird)
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder2/"]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/file1.txt/"]);
    
    // Invalid paths. Must not alter the value of isDirectory
    BOOL isDirectory11 = YES;
    XCTAssertFalse([fileManager fileExistsAtPath:@"invalid/path" isDirectory:&isDirectory11]);
    XCTAssertTrue(isDirectory11);
    
    // Existence of the root folder
    BOOL isDirectory12 = NO;
    XCTAssertTrue([fileManager fileExistsAtPath:@"/" isDirectory:&isDirectory12]);
    XCTAssertTrue(isDirectory12);
}

- (void)testCopyWithFileManager:(HLSFileManager *)fileManager
{
    // Create some files and folders
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder3" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/file31.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/file32.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder3/folder33" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/folder33/file331.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/copy" withIntermediateDirectories:YES error:NULL]);
    
    // File copy to an existing folder. Must succeed
    NSError *error1 = nil;
    XCTAssertTrue([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/copy/file1.txt" error:&error1]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/file1.txt"]);
    XCTAssertNil(error1);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/copy/file1.txt" error:&error1], data);
    XCTAssertNil(error1);
    
    // File copy to a non-existing folder. Must fail
    NSError *error2 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/invalid/file1.txt" error:&error2]);
    XCTAssertNotNil(error2);
    
    // File copy onto an existing file. Must fail
    NSError *error3 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/copy/file1.txt" error:&error3]);
    XCTAssertNotNil(error3);
    
    // File copy onto an existing folder. Must fail
    NSError *error4 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/file1.txt" toPath:@"/copy" error:&error4]);
    XCTAssertNotNil(error4);
    
    // Folder copy to an existing folder. Must succceed and copy recursively
    NSError *error5 = nil;
    XCTAssertTrue([fileManager copyItemAtPath:@"/folder3" toPath:@"/copy/folder3" error:&error5]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder3"]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder3/file31.txt"]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder3/folder33/file331.txt"]);
    XCTAssertNil(error5);
    XCTAssertEqual([[fileManager contentsOfDirectoryAtPath:@"/copy/folder3" error:&error5] count], (NSUInteger)3);
    XCTAssertNil(error5);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/copy/folder3/file31.txt" error:&error5], data);
    XCTAssertNil(error5);
    XCTAssertEqual([[fileManager contentsOfDirectoryAtPath:@"/copy/folder3/folder33" error:&error5] count], (NSUInteger)1);
    XCTAssertNil(error5);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/copy/folder3/folder33/file331.txt" error:&error5], data);
    XCTAssertNil(error5);
    
    // Folder copy to a non-existing folder. Must fail
    NSError *error6 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/folder3" toPath:@"/invalid/folder3" error:&error6]);
    XCTAssertNotNil(error6);
    
    // Folder copy onto an existing folder. Must fail
    NSError *error7 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/folder3" toPath:@"/copy/folder3" error:&error7]);
    XCTAssertNotNil(error7);
    
    // Folder copy onto an existing file. Must fail
    NSError *error8 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/folder3" toPath:@"/copy/file1.txt" error:&error8]);
    XCTAssertNotNil(error8);
    
    // Missing copy source file. Must fail
    NSError *error9 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/invalid.txt" toPath:@"/copy/invalid.txt" error:&error9]);
    XCTAssertNotNil(error9);
    
    // Copy existing file onto itself. Must fail
    NSError *error10 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"@/file1.txt" toPath:@"/file1.txt" error:&error10]);
    XCTAssertNotNil(error10);
    
    // Copy existing directory onto itself. Must fail
    NSError *error11 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/folder2" toPath:@"/folder2" error:&error11]);
    XCTAssertNotNil(error11);
    
    // Copy existing directory to a subfolder of itself (potential recursion issues). Must fail
    NSError *error12 = nil;
    XCTAssertFalse([fileManager copyItemAtPath:@"/folder2/" toPath:@"/folder2/folder2" error:&error12]);
    XCTAssertNotNil(error12);
    
    // Try deleting the copy of a file. The original data must still be accessible, i.e. the copy must be deep
    NSError *error13 = nil;
    XCTAssertTrue([fileManager removeItemAtPath:@"/copy/file1.txt" error:&error13]);
    XCTAssertNil(error13);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/file1.txt" error:&error13], data);
}

- (void)testMoveWithFileManager:(HLSFileManager *)fileManager
{
    // Create some files and folders
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/file4.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder3" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/file31.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/file32.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder3/folder33" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder3/folder33/file331.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/move" withIntermediateDirectories:YES error:NULL]);
    
    // File move to an existing folder. Must succeed
    NSError *error1 = nil;
    XCTAssertTrue([fileManager moveItemAtPath:@"/file1.txt" toPath:@"/move/file1.txt" error:&error1]);
    XCTAssertFalse([fileManager fileExistsAtPath:@"/file1.txt"]);
    XCTAssertNil(error1);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/move/file1.txt" error:&error1], data);
    XCTAssertNil(error1);
    
    // File move to a non-existing folder. Must fail
    NSError *error2 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/file4.txt" toPath:@"/invalid/file4.txt" error:&error2]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/file4.txt"]);
    XCTAssertNotNil(error2);
    
    // File move onto an existing file. Must fail
    NSError *error3 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/file4.txt" toPath:@"/move/file1.txt" error:&error3]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/file4.txt"]);
    XCTAssertNotNil(error3);
    
    // File move onto an existing folder. Must fail
    NSError *error4 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/file4.txt" toPath:@"/move" error:&error4]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/file4.txt"]);
    XCTAssertNotNil(error4);
    
    // Folder move to an existing folder. Must succceed and move recursively
    NSError *error5 = nil;
    XCTAssertTrue([fileManager moveItemAtPath:@"/folder3" toPath:@"/move/folder3" error:&error5]);
    XCTAssertFalse([fileManager fileExistsAtPath:@"/folder3"]);
    XCTAssertNil(error5);
    XCTAssertEqual([[fileManager contentsOfDirectoryAtPath:@"/move/folder3" error:&error5] count], (NSUInteger)3);
    XCTAssertNil(error5);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/move/folder3/file31.txt" error:&error5], data);
    XCTAssertNil(error5);
    XCTAssertEqual([[fileManager contentsOfDirectoryAtPath:@"/move/folder3/folder33" error:&error5] count], (NSUInteger)1);
    XCTAssertNil(error5);
    XCTAssertEqualObjects([fileManager contentsOfFileAtPath:@"/move/folder3/folder33/file331.txt" error:&error5], data);
    XCTAssertNil(error5);
    
    // Folder move to a non-existing folder. Must fail
    NSError *error6 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/folder2" toPath:@"/invalid/folder2" error:&error6]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder2"]);
    XCTAssertNotNil(error6);
    
    // Folder move onto an existing folder. Must fail
    NSError *error7 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/folder2" toPath:@"/move/folder3" error:&error7]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder2"]);
    XCTAssertNotNil(error7);
    
    // Folder move onto an existing file. Must fail
    NSError *error8 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/folder2" toPath:@"/move/file1.txt" error:&error8]);
    XCTAssertTrue([fileManager fileExistsAtPath:@"/folder2"]);
    XCTAssertNotNil(error8);
    
    // Missing move source file. Must fail
    NSError *error9 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/invalid.txt" toPath:@"/move/invalid.txt" error:&error9]);
    XCTAssertNotNil(error9);
    
    // Move existing directory onto itself. Must fail
    NSError *error10 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/folder2" toPath:@"/folder2" error:&error10]);
    XCTAssertNotNil(error10);
    
    // Move existing directory to a subfolder of itself (potential recursion issues). Must fail
    NSError *error11 = nil;
    XCTAssertFalse([fileManager moveItemAtPath:@"/folder2/" toPath:@"/folder2/folder2" error:&error11]);
    XCTAssertNotNil(error11);
}

- (void)testStreamsWithFileManager:(HLSFileManager *)fileManager
{
    // Create test file and folder
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL]);
    
    if (fileManager.providingInputStreams) {
        // Input stream with existing file. Must succeeed
        NSInputStream *inputStream1 = [fileManager inputStreamWithFileAtPath:@"/file1.txt"];
        XCTAssertNotNil(inputStream1);
        NSOutputStream *outputStream1 = [NSOutputStream outputStreamToMemory];
        XCTAssertTrue([inputStream1 writeToOutputStream:outputStream1 error:NULL]);
        XCTAssertEqualObjects([outputStream1 propertyForKey:NSStreamDataWrittenToMemoryStreamKey], data);
        
        // Input stream with non-existing file. Must fail
        XCTAssertNil([fileManager inputStreamWithFileAtPath:@"/invalid.txt"]);
        
        // Input stream with folder. Must fail
        XCTAssertNil([fileManager inputStreamWithFileAtPath:@"/folder2"]);
    }
    else {
        XCTAssertThrows([fileManager inputStreamWithFileAtPath:@"/file1.txt"]);
    }
    
    if (fileManager.providingOutputStreams) {
        // Ouput stream to new file. Must succeed
        NSOutputStream *outputStream2 = [fileManager outputStreamToFileAtPath:@"/file2.txt" append:NO];
        XCTAssertNotNil(outputStream2);
        NSData *data2 = [@"Hello" dataUsingEncoding:NSUTF8StringEncoding];
        NSInputStream *inputStream2 = [NSInputStream inputStreamWithData:data2];
        XCTAssertTrue([inputStream2 writeToOutputStream:outputStream2 error:NULL]);
        NSData *outData2 = [fileManager contentsOfFileAtPath:@"/file2.txt" error:NULL];
        XCTAssertEqualObjects(data2, outData2);
        
        // Output stream to existing file (and append). Must succeed
        NSOutputStream *outputStream3 = [fileManager outputStreamToFileAtPath:@"/file2.txt" append:YES];
        XCTAssertNotNil(outputStream3);
        NSInputStream *inputStream3 = [NSInputStream inputStreamWithData:[@", World!" dataUsingEncoding:NSUTF8StringEncoding]];
        XCTAssertTrue([inputStream3 writeToOutputStream:outputStream3 error:NULL]);
        NSData *outData3 = [fileManager contentsOfFileAtPath:@"/file2.txt" error:NULL];
        XCTAssertEqualObjects([@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding], outData3);
        
        // Output stream to existing folder. Must fail
        XCTAssertNil([fileManager outputStreamToFileAtPath:@"/folder2" append:NO]);
    }
    else {
        XCTAssertThrows([fileManager outputStreamToFileAtPath:@"/file2.txt" append:NO]);
    }
}

- (void)testURLsWithFileManager:(HLSFileManager *)fileManager
{
    // Create test file and folder
    NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileManager createFileAtPath:@"/file1.txt" contents:data error:NULL]);
    XCTAssertTrue([fileManager createDirectoryAtPath:@"/folder2" withIntermediateDirectories:YES error:NULL]);
    XCTAssertTrue([fileManager createFileAtPath:@"/folder2/file21.txt" contents:data error:NULL]);
    
    if (fileManager.providingURLs) {        
        // URL to existing file
        NSURL *URL1 = [fileManager URLForFileAtPath:@"/file1.txt"];
        XCTAssertNotNil(URL1);
        XCTAssertEqualObjects([NSData dataWithContentsOfURL:URL1], data);
        
        // URLs to existing folders
        XCTAssertNotNil([fileManager URLForFileAtPath:@"/folder2"]);
        XCTAssertNotNil([fileManager URLForFileAtPath:@"/"]);
        
        // URLs to a non-existing files
        XCTAssertNil([fileManager URLForFileAtPath:@"/invalid"]);
        XCTAssertNil([fileManager URLForFileAtPath:@"invalid"]);
    }
    else {
        XCTAssertThrows([fileManager URLForFileAtPath:@"file1.txt"]);
    }
}

@end
