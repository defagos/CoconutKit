//
//  HLSFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSFileManager.h"

@implementation HLSFileManager

#pragma mark Accessors and mutators

- (BOOL)isProvidingInputStreams
{
    return [self respondsToSelector:@selector(inputStreamWithFileAtPath:)];
}

- (BOOL)isProvidingOutputStreams
{
    return [self respondsToSelector:@selector(outputStreamToFileAtPath:append:)];
}

- (BOOL)isProvidingURLs
{
    return [self respondsToSelector:@selector(URLForFileAtPath:)];
}

#pragma mark Convenience methods

- (BOOL)fileExistsAtPath:(NSString *)path
{
    return [self fileExistsAtPath:path isDirectory:NULL];
}

@end
