//
//  HLSFileManagerTestCase.h
//  CoconutKit-test
//
//  Created by Samuel Défago on 21.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface HLSFileManagerTestCase : GHTestCase

- (void)testCreationAndRemovalWithFileManager:(HLSFileManager *)fileManager;
- (void)testContentsAndExistenceWithFileManager:(HLSFileManager *)fileManager;
- (void)testCopyWithFileManager:(HLSFileManager *)fileManager;
- (void)testMoveWithFileManager:(HLSFileManager *)fileManager;
- (void)testStreamsWithFileManager:(HLSFileManager *)fileManager;
- (void)testURLsWithFileManager:(HLSFileManager *)fileManager;

@end
