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
    static NSBundle *s_coconutKitBundle = nil;
    if (! s_coconutKitBundle) {
        NSString *coconutKitPath = [[NSBundle mainBundle] pathForResource:@"CoconutKit-resources" ofType:@"bundle"];
        s_coconutKitBundle = [[NSBundle alloc] initWithPath:coconutKitPath];
        if (! s_coconutKitBundle) {
            HLSLoggerError(@"Could not load CoconutKit-resources bundle. Have you added it to your project?");
        }
    }
    return s_coconutKitBundle;
}

@end
