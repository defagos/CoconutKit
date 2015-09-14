//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@interface HLSFileManagerTestCase : XCTestCase

- (void)testCreationAndRemovalWithFileManager:(HLSFileManager *)fileManager;
- (void)testContentsAndExistenceWithFileManager:(HLSFileManager *)fileManager;
- (void)testCopyWithFileManager:(HLSFileManager *)fileManager;
- (void)testMoveWithFileManager:(HLSFileManager *)fileManager;
- (void)testStreamsWithFileManager:(HLSFileManager *)fileManager;
- (void)testURLsWithFileManager:(HLSFileManager *)fileManager;

@end
