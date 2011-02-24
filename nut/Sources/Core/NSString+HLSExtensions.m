//
//  NSString+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 11/3/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSString+HLSExtensions.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (HLSExtensions)

#pragma mark Hash digests

- (NSString *)md5hash
{
    // Calculate the MD5 hash
    const char *utf8str = [self UTF8String];
    unsigned char resultBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(utf8str, strlen(utf8str), resultBuffer);
    
    // Hexadecimal representation
    NSMutableString *hexHash = [NSMutableString string];
    for (NSUInteger i = 0; i < 16; ++i) {
        [hexHash appendFormat:@"%02X", resultBuffer[i]];
    }
    return [hexHash lowercaseString];
}

#pragma mark Version strings

- (NSString *)friendlyVersionNumber
{
    NSArray *versionComponents = [self componentsSeparatedByString:@"+"];
    if ([versionComponents count] > 1) {
        NSString *lastComponent = [versionComponents lastObject];
        if (! [lastComponent isEqualToString:@"dev"] && ! [lastComponent isEqualToString:@"test"]) {
            return lastComponent;
        }
    }
    return self;
}

@end
