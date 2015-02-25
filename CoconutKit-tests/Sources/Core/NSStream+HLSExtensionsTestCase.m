//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSStream+HLSExtensionsTestCase.h"

@implementation NSStream_HLSExtensionsTestCase

- (void)testWrite
{
    NSString *filePath = [[NSBundle principalBundle] pathForResource:@"Sample" ofType:@"txt"];
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
