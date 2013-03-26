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

+ (NSString *)friendlyApplicationVersionNumber
{
    return [[NSBundle mainBundle] friendlyVersionNumber];
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
    
    NSBundle *bundle = [self bundleWithName:name inDirectory:[[NSBundle mainBundle] bundlePath]];
    if (bundle) {
        return bundle;
    }
    
    // TODO: Use CoconutKit method returning the library folder (available on a branch)
    NSString *libraryDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    bundle = [self bundleWithName:name inDirectory:libraryDirectoryPath];
    if (bundle) {
        return bundle;
    }
    
    // Search again, but with the .bundle extension appended
    if (! [[name pathExtension] isEqualToString:@"bundle"]) {
        NSString *nameDotBundle = [name stringByAppendingPathExtension:@"bundle"];
        bundle = [self bundleWithName:nameDotBundle];
    }
    return bundle;
}

+ (NSBundle *)bundleWithName:(NSString *)name inDirectory:(NSString *)directoryPath
{
    if (! directoryPath) {
        directoryPath = [[NSBundle mainBundle] bundlePath];
    }
    
    static NSMutableDictionary *s_nameToBundleMap = nil;
    if (! s_nameToBundleMap) {
        s_nameToBundleMap = [[NSMutableDictionary alloc] init];
    }
    
    NSBundle *bundle = [s_nameToBundleMap objectForKey:name];
    if (! bundle) {
        NSArray *contentPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:directoryPath error:NULL];
        for (NSString *contentPath in contentPaths) {
            NSString *lastPathComponent = [contentPath lastPathComponent];
            if (! [lastPathComponent isEqualToString:name]) {
                continue;
            }
            
            NSString *bundlePath = [directoryPath stringByAppendingPathComponent:contentPath];
            bundle = [NSBundle bundleWithPath:bundlePath];
            if (! bundle) {
                continue;
            }
            
            [s_nameToBundleMap setObject:bundle forKey:name];
            break;
        }        
    }
    return bundle;
}

#pragma mark Accessors and mutators

- (NSString *)friendlyVersionNumber
{
    NSString *versionNumber = [[self infoDictionary] objectForKey:@"CFBundleVersion"];
    return [versionNumber friendlyVersionNumber];
}

@end
