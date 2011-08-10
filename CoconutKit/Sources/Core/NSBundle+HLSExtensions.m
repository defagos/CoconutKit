//
//  NSUserDefaults+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSBundle+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "NSString+HLSExtensions.h"

HLSLinkCategory(NSBundle_HLSExtensions)

@implementation NSBundle (HLSExtensions)

+ (NSString *)friendlyVersionNumber
{
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [versionNumber friendlyVersionNumber];
}

+ (NSBundle *)CoconutKitBundle
{
    static NSBundle *CoconutKitBundle = nil;
    if (CoconutKitBundle == nil) {
        NSString *CoconutKitPath = [[NSBundle mainBundle] pathForResource:@"CoconutKit" ofType:@"bundle"];
        CoconutKitBundle = [[NSBundle alloc] initWithPath:CoconutKitPath];
    }
    return CoconutKitBundle;
}

@end
