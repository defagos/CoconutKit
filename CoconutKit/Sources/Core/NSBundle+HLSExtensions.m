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

+ (NSBundle *)coconutKitBundle
{
    static NSBundle *coconutKitBundle = nil;
    if (! coconutKitBundle) {
        NSString *coconutKitPath = [[NSBundle mainBundle] pathForResource:@"CoconutKit" ofType:@"bundle"];
        coconutKitBundle = [[NSBundle alloc] initWithPath:coconutKitPath];
    }
    return coconutKitBundle;
}

@end
