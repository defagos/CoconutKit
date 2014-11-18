//
//  NSStream+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.10.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "NSStream+HLSExtensions.h"

#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"

#define BUFFER_SIZE 4096

@implementation NSInputStream (HLSExtensions)

- (BOOL)writeToOutputStream:(NSOutputStream *)outputStream error:(NSError *__autoreleasing *)pError
{
    if (self.streamStatus != NSStreamStatusNotOpen && self.streamStatus != NSStreamStatusClosed
            && outputStream.streamStatus != NSStreamStatusNotOpen && outputStream.streamStatus != NSStreamStatusClosed) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileReadUnknownError
                          localizedDescription:CoconutKitLocalizedString(@"The streams must not be opened", nil)];
        }
        return NO;
    }
    
    [self open];
    [outputStream open];
    
    BOOL success = YES;
    while (1) {
        uint8_t bytes[BUFFER_SIZE] = {0};
        NSInteger length = [self read:bytes maxLength:BUFFER_SIZE];
        
        // Error
        if (length < 0) {
            success = NO;
            break;
        }
        // End of stream, marked with a sentinel data block
        else if (length == 0) {
            break;
        }
        // More data
        else {
            [outputStream write:bytes maxLength:length];
        }
    }
    
    [self close];
    [outputStream close];
    
    if (! success) {
        if (pError) {
            *pError = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSFileReadUnknownError
                          localizedDescription:CoconutKitLocalizedString(@"The input stream could not be read", nil)];
        }
        return NO;
    }
    
    return YES;
}

@end
