//
//  HLSApplicationInformation.m
//  CoconutKit
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSApplicationInformation.h"

#import "NSArray+HLSExtensions.h"

NSString *HLSApplicationLibraryDirectoryPath(void)
{
    static NSString *s_path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    });
    return s_path;
}

NSURL *HLSApplicationLibraryDirectoryURL(void)
{
    static NSURL *s_URL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_URL = [NSURL fileURLWithPath:HLSApplicationLibraryDirectoryPath()];
    });
    return s_URL;
}

NSString *HLSApplicationCachesDirectoryPath(void)
{
    static NSString *s_path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    });
    return s_path;
}

NSURL *HLSApplicationCachesDirectoryURL(void)
{
    static NSURL *s_URL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_URL = [NSURL fileURLWithPath:HLSApplicationCachesDirectoryPath()];
    });
    return s_URL;
}

NSString *HLSApplicationDocumentDirectoryPath(void)
{
    static NSString *s_path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    });
    return s_path;
}

NSURL *HLSApplicationDocumentDirectoryURL(void)
{
    static NSURL *s_URL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_URL = [NSURL fileURLWithPath:HLSApplicationDocumentDirectoryPath()];
    });
    return s_URL;
}

NSString *HLSApplicationTemporaryDirectoryPath(void)
{
    static NSString *s_path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_path = NSTemporaryDirectory();
    });
    return s_path;
}

NSURL *HLSApplicationTemporaryDirectoryURL(void)
{
    static NSURL *s_URL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_URL = [NSURL fileURLWithPath:HLSApplicationTemporaryDirectoryPath()];
    });
    return s_URL;
}

NSString *HLSApplicationInboxDirectoryPath(void)
{
    static NSString *s_path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_path = [HLSApplicationDocumentDirectoryPath() stringByAppendingPathComponent:@"Inbox"];
    });
    return s_path;
}

NSURL *HLSApplicationInboxDirectoryURL(void)
{
    static NSURL *s_URL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_URL = [NSURL fileURLWithPath:HLSApplicationInboxDirectoryPath()];
    });
    return s_URL;
}
