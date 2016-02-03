//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSBundle+Tests.h"

#import "UppercaseValueTransformer.h"

@implementation NSBundle (Tests)

+ (NSBundle *)testBundle
{
    static NSBundle *s_testBundle;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_testBundle = [NSBundle bundleForClass:[UppercaseValueTransformer class]];
    });
    return s_testBundle;
}

@end
