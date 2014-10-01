//
//  HLSFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSFileManager.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"

@implementation HLSFileManager

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        // Check protocol conformance when instantiating concrete classes
        if (! hls_class_implementsProtocol([self class], @protocol(HLSFileManagerAbstract))) {
            HLSLoggerError(@"The class %@ does not completely implement the HLSFileManagerAbstract protocol", [self class]);
            return nil;
        }
    }
    return self;
}

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
