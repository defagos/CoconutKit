//
//  NSUserDefaults+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSBundle+HLSExtensions.h"

#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

@implementation NSBundle (HLSExtensions)

+ (NSString *)friendlyVersionNumber
{
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [versionNumber friendlyVersionNumber];
}

+ (NSBundle *)coconutKitBundle
{
    // Search in all subdirectories as well. In general, a bundle is copied at the main bundle root, but this
    // might not be the case
    static NSBundle *s_coconutKitBundle = nil;
    if (! s_coconutKitBundle) {
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSError *error = nil;
        NSArray *contentPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:mainBundlePath error:&error];
        if (error) {
            HLSLoggerError(@"Could not find CoconutKit-resources bundle. Reason: %@", error);
            return nil;
        }
        
        for (NSString *contentPath in contentPaths) {
            if ([[contentPath lastPathComponent] isEqualToString:@"CoconutKit-resources.bundle"]) {
                NSString *coconutKitBundlePath = [mainBundlePath stringByAppendingPathComponent:contentPath];
                s_coconutKitBundle = [[NSBundle alloc] initWithPath:coconutKitBundlePath];
                break;
            }
        }
        
        if (! s_coconutKitBundle) {
            HLSLoggerError(@"Could not load CoconutKit-resources bundle. Have you added it to your project main bundle?");
        }        
    }
    return s_coconutKitBundle;
}

@end
