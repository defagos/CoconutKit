//
//  HLSFileManager.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSFileManager.h"

// TODO: When available in CoconutKit (feature/url-connection branch), check protocol conformance (all methods from the
//       abstract protocol must be implemented, though they have been made optional to avoid compilation warnings)

static HLSFileManager *s_defaultManager = nil;

@implementation HLSFileManager

#pragma mark Class methods

+ (HLSFileManager *)setDefaultManager:(HLSFileManager *)defaultManager
{
    @synchronized(self) {
        HLSFileManager *previousManager = [s_defaultManager autorelease];
        s_defaultManager = [defaultManager retain];
        return previousManager;
    }
}

+ (HLSFileManager *)defaultManager
{
    @synchronized(self) {
        return s_defaultManager;
    }
}

#pragma mark Convenience methods

- (BOOL)fileExistsAtPath:(NSString *)path
{
    return [self fileExistsAtPath:path isDirectory:NULL];
}

@end
