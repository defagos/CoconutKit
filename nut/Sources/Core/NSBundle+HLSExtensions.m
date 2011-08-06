//
//  NSUserDefaults+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSBundle+HLSExtensions.h"

#import "NSString+HLSExtensions.h"
#import "HLSCategoryLinker.h"

HLSLinkCategory(NSBundle_HLSExtensions)

@implementation NSBundle (HLSExtensions)

+ (NSString *)friendlyVersionNumber
{
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [versionNumber friendlyVersionNumber];
}

+ (NSBundle *)nutBundle
{
    static NSBundle *nutBundle = nil;
    if (nutBundle == nil) {
        NSString *nutPath = [[NSBundle mainBundle] pathForResource:@"nut" ofType:@"bundle"];
        nutBundle = [[NSBundle alloc] initWithPath:nutPath];
    }
    return nutBundle;
}

@end
