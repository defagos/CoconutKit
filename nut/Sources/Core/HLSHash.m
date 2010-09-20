//
//  HLSHash.m
//  nut
//
//  Created by Samuel Défago on 9/20/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSHash.h"

#import <CommonCrypto/CommonDigest.h>

@implementation HLSHash

+ (NSString *)md5hashForString:(NSString *)string
{
    // Calculate the MD5 hash
    const char *utf8str = [string UTF8String];
    unsigned char resultBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(utf8str, strlen(utf8str), resultBuffer);
    
    // Hexadecimal representation
    NSMutableString *hexHash = [NSMutableString string];
    for (NSUInteger i = 0; i < 16; ++i) {
        [hexHash appendFormat:@"%02X", resultBuffer[i]];
    }
    return [hexHash lowercaseString];
}

@end
