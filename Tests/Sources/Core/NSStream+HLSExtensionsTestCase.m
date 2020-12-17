//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSBundle+Tests.h"

@import CoconutKit;
@import XCTest;

@interface NSStream_HLSExtensionsTestCase : XCTestCase
@end

@implementation NSStream_HLSExtensionsTestCase

- (void)testWrite
{
    NSString *filePath = [[NSBundle testBundle] pathForResource:@"Sample" ofType:@"txt"];
    NSData *sampleData = [NSData dataWithContentsOfFile:filePath];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:sampleData];
    
    NSError *error = nil;
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    XCTAssertTrue([inputStream writeToOutputStream:outputStream error:&error]);
    XCTAssertNil(error);
    
    NSData *outputStreamData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssertEqualObjects(sampleData, outputStreamData);
}

@end
