//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSBundle+HLSExtensions.h"

#import "HLSApplicationInformation.h"
#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

@implementation NSBundle (HLSExtensions)

#pragma mark Class methods

+ (NSBundle *)principalBundle
{
    static NSBundle *s_principalBundle;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_principalBundle = [NSBundle bundleForClass:[HLSLogger class]];
    });
    return s_principalBundle;
}

+ (NSString *)friendlyApplicationVersionNumber
{
    return [[NSBundle principalBundle] friendlyVersionNumber];
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
        return [NSBundle principalBundle];
    }
    
    static NSMutableDictionary *s_nameToBundleMap = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_nameToBundleMap = [[NSMutableDictionary alloc] init];
    });
    
    NSBundle *bundle = [s_nameToBundleMap objectForKey:name];
    if (bundle) {
        return bundle;
    }
    NSString *nameDotBundle = [name stringByAppendingPathExtension:@"bundle"];
    bundle = [s_nameToBundleMap objectForKey:nameDotBundle];
    if (bundle) {
        return bundle;
    }
    
    bundle = [self bundleWithName:name inDirectory:[[NSBundle principalBundle] bundlePath]];
    if (bundle) {
        [s_nameToBundleMap setObject:bundle forKey:name];
        return bundle;
    }
    
    bundle = [self bundleWithName:name inDirectory:HLSApplicationLibraryDirectoryPath()];
    if (bundle) {
        [s_nameToBundleMap setObject:bundle forKey:name];
        return bundle;
    }
    
    bundle = [self bundleWithName:name inDirectory:HLSApplicationDocumentDirectoryPath()];
    if (bundle) {
        [s_nameToBundleMap setObject:bundle forKey:name];
        return bundle;
    }
    
    // Search again, but with the .bundle extension appended
    if (! [[name pathExtension] isEqualToString:@"bundle"]) {
        bundle = [self bundleWithName:nameDotBundle];
    }
    
    if (! bundle) {
        HLSLoggerWarn(@"No bundle named %@ was found in the main bundle, Library or Documents directory", name);
    }
    
    return bundle;
}

+ (NSBundle *)bundleWithName:(NSString *)name inDirectory:(NSString *)directoryPath
{
    if (! directoryPath) {
        directoryPath = [[NSBundle principalBundle] bundlePath];
    }
    
    NSBundle *bundle = nil;
    NSArray *contentPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:directoryPath error:NULL];
    for (NSString *contentPath in contentPaths) {
        NSString *lastPathComponent = [contentPath lastPathComponent];
        if (! [lastPathComponent isEqualToString:name]) {
            continue;
        }
        
        NSString *bundlePath = [directoryPath stringByAppendingPathComponent:contentPath];
        bundle = [NSBundle bundleWithPath:bundlePath];
        if (bundle) {
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
