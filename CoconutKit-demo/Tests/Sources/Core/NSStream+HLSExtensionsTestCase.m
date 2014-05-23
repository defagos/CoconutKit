//
//  NSStream+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 14.10.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "NSStream+HLSExtensionsTestCase.h"

@implementation NSStream_HLSExtensionsTestCase

- (void)testWrite
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"txt"];
    NSData *sampleData = [NSData dataWithContentsOfFile:filePath];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:sampleData];
    
    NSError *error = nil;
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    GHAssertTrue([inputStream writeToOutputStream:outputStream error:&error], nil);
    GHAssertNil(error, nil);
    
    NSData *outputStreamData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    GHAssertEqualObjects(sampleData, outputStreamData, nil);
}

@end
