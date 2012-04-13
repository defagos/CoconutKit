//
//  HLSApplicationInformation.m
//  CoconutKit
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSApplicationInformation.h"

#import "NSArray+HLSExtensions.h"

NSString *HLSApplicationLibraryDirectoryPath(void)
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

NSURL *HLSApplicationLibraryDirectoryURL(void)
{
    return [NSURL fileURLWithPath:HLSApplicationLibraryDirectoryPath()];
}

NSString *HLSApplicationDocumentDirectoryPath(void)
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

NSURL *HLSApplicationDocumentDirectoryURL(void)
{
    return [NSURL fileURLWithPath:HLSApplicationDocumentDirectoryPath()];
}

NSString *HLSApplicationTemporaryDirectoryPath(void)
{
    return NSTemporaryDirectory();
}

NSURL *HLSApplicationTemporaryDirectoryURL(void)
{
    return [NSURL fileURLWithPath:HLSApplicationTemporaryDirectoryPath()];
}
