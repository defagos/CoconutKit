//
//  HLSFileManagerTestCase.h
//  CoconutKit-test
//
//  Created by Samuel Défago on 21.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface HLSFileManagerTestCase : GHTestCase

- (void)testCreationWithFileManager:(HLSFileManager *)fileManager;
- (void)testContentsWithFileManager:(HLSFileManager *)fileManager;
- (void)testStreamsWithFileManager:(HLSFileManager *)fileManager;

@end
