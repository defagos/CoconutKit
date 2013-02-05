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

#pragma mark Class methods

+ (NSString *)friendlyVersionNumber
{
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [versionNumber friendlyVersionNumber];
}

+ (NSBundle *)coconutKitBundle
{
    NSBundle *coconutKitBundle = [self bundleWithName:@"CoconutKit-resources"];
    if (! coconutKitBundle) {
        HLSLoggerError(@"Could not find CoconutKit-resources bundle. Have you added it to your project main bundle?");
    }
    return coconutKitBundle;
}

+ (NSBundle *)bundleWithName:(NSString *)name
{
    if (! name) {
        return [NSBundle mainBundle];
    }
    
    static NSMutableDictionary *s_nameToBundleMap = nil;
    if (! s_nameToBundleMap) {
        s_nameToBundleMap = [[NSMutableDictionary alloc] init];
    }
    
    NSBundle *bundle = [s_nameToBundleMap objectForKey:name];
    if (! bundle) {
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSArray *contentPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:mainBundlePath error:NULL];
        for (NSString *contentPath in contentPaths) {
            NSString *lastPathComponent = [contentPath lastPathComponent];
            if (! [lastPathComponent isEqualToString:name]) {
                continue;
            }
            
            NSString *bundlePath = [mainBundlePath stringByAppendingPathComponent:contentPath];
            bundle = [NSBundle bundleWithPath:bundlePath];
            if (! bundle) {
                continue;
            }
            
            [s_nameToBundleMap setObject:bundle forKey:name];
            break;
        }
        
        if (! bundle && ! [[name pathExtension] isEqualToString:@"bundle"]) {
            NSString *nameDotBundle = [name stringByAppendingPathExtension:@"bundle"];
            bundle = [self bundleWithName:nameDotBundle];
            [s_nameToBundleMap setObject:bundle forKey:name];
        }
    }
    return bundle;
}

@end
