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
    
    static NSDictionary *s_nameToBundleMap = nil;
    if (! s_nameToBundleMap) {
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSError *error = nil;
        NSArray *contentPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:mainBundlePath error:&error];
        if (error) {
            return nil;
        }
        
        NSMutableDictionary *nameToBundleMap = [NSMutableDictionary dictionary];
        for (NSString *contentPath in contentPaths) {
            if ([[contentPath pathExtension] isEqualToString:@"bundle"]) {
                NSString *bundlePath = [mainBundlePath stringByAppendingPathComponent:contentPath];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                NSString *bundleName = [[bundlePath lastPathComponent] stringByDeletingPathExtension];
                [nameToBundleMap setObject:bundle forKey:bundleName];
            }
        }
        s_nameToBundleMap = [[NSDictionary dictionaryWithDictionary:nameToBundleMap] retain];
    }
    return [s_nameToBundleMap objectForKey:name];
}

@end
