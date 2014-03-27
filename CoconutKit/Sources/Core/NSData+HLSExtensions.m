//
//  NSData+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSData+HLSExtensions.h"

#import <CommonCrypto/CommonDigest.h>

/**
 * These methods have first been exposed with iOS 7, but can be used on iOS 4 and above (see Apple documentation)
 */
@interface NSData (HLSExtensionsBase64)

- (id)initWithBase64Encoding:(NSString *)base64String;
- (NSString *)base64Encoding;

@end

static NSString* digest(NSData *data, unsigned char *(*cc_digest)(const void *, CC_LONG, unsigned char *), CC_LONG digestLength)
{
	unsigned char md[digestLength];     // C99
    memset(md, 0, sizeof(md));
	cc_digest([data bytes], (CC_LONG)[data length], md);
    
    // Hexadecimal representation
    NSMutableString *hexHash = [NSMutableString string];
    for (NSUInteger i = 0; i < sizeof(md); ++i) {
        [hexHash appendFormat:@"%02X", md[i]];
    }
    
    return [hexHash lowercaseString];
}

@implementation NSData (HLSExtensions)

#pragma mark Class methods

+ (instancetype)dataWithBase64EncodedString:(NSString *)base64EncodedString
{
    return [[[self alloc] initWithBase64EncodedString:base64EncodedString] autorelease];
}

+ (instancetype)dataWithBase64EncodedData:(NSData *)base64EncodedData
{
    return [[[self alloc] initWithBase64EncodedData:base64EncodedData] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithBase64EncodedString:(NSString *)base64String
{
    return [self initWithBase64Encoding:base64String];
}

- (id)initWithBase64EncodedData:(NSData *)base64Data
{
    NSString *base64DataString = [[[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding] autorelease];
    return [self initWithBase64EncodedString:base64DataString];
}

#pragma mark Base 64 encoding

- (NSString *)base64EncodedString
{
    return [self base64Encoding];
}

- (NSData *)base64EncodedData
{
    return [[self base64EncodedString] dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark Digest methods

- (NSString *)md2hash
{
    return digest(self, CC_MD2, CC_MD2_DIGEST_LENGTH);
}

- (NSString *)md4hash
{
    return digest(self, CC_MD4, CC_MD4_DIGEST_LENGTH);
}

- (NSString *)md5hash
{
    return digest(self, CC_MD5, CC_MD5_DIGEST_LENGTH);
}

- (NSString *)sha1hash
{
    return digest(self, CC_SHA1, CC_SHA1_DIGEST_LENGTH);
}

- (NSString *)sha224hash
{
    return digest(self, CC_SHA224, CC_SHA224_DIGEST_LENGTH);
}

- (NSString *)sha256hash
{
    return digest(self, CC_SHA256, CC_SHA256_DIGEST_LENGTH);
}

- (NSString *)sha384hash
{
    return digest(self, CC_SHA384, CC_SHA384_DIGEST_LENGTH);
}

- (NSString *)sha512hash
{
    return digest(self, CC_SHA512, CC_SHA512_DIGEST_LENGTH);
}

@end
