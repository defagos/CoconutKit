//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSString+HLSExtensions.h"

#import "HLSLogger.h"
#import "NSData+HLSExtensions.h"

#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>

static NSString* digest(NSString *string, unsigned char *(*cc_digest)(const void *, CC_LONG, unsigned char *), CC_LONG digestLength)
{
    // Hash calculation
	unsigned char md[digestLength];     // C99
    memset(md, 0, sizeof(md));
    const char *utf8str = string.UTF8String;
	cc_digest(utf8str, (CC_LONG)strlen(utf8str), md);
    
    // Hexadecimal representation
    NSMutableString *hexHash = [NSMutableString string];
    for (NSUInteger i = 0; i < sizeof(md); ++i) {
        [hexHash appendFormat:@"%02X", md[i]];
    }
    
    return hexHash.lowercaseString;
}

@implementation NSString (HLSExtensions)

#pragma mark Convenience methods

- (NSString *)stringByTrimmingWhitespaces
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isFilled
{
    return self.stringByTrimmingWhitespaces.length != 0;
}

#pragma mark Hash digests

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

#pragma mark Version strings

- (NSString *)friendlyVersionNumber
{
    NSArray<NSString *> *versionComponents = [self componentsSeparatedByString:@"+"];
    if (versionComponents.count > 1) {
        NSString *lastComponent = versionComponents.lastObject;
        if (! [lastComponent isEqualToString:@"dev"] && ! [lastComponent isEqualToString:@"test"]) {
            return lastComponent;
        }
    }
    return self;
}

- (NSString *)MIMEType
{
    NSString *pathExtension = self.pathExtension;
    if (! pathExtension) {
        return nil;
    }
    
    CFStringRef identifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)pathExtension, NULL);
    if (! identifier) {
        return nil;
    }
    
    NSString *MIMEType = (NSString *)CFBridgingRelease(UTTypeCopyPreferredTagWithClass(identifier, kUTTagClassMIMEType));
    CFRelease(identifier);
    return MIMEType;
}

@end
