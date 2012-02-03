//
//  NSString+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 11/3/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Formatting functions
NSString *HLSStringFromCATransform3D(CATransform3D transform);

@interface NSString (HLSExtensions)

/**
 * Trims spaces left and right
 */
- (NSString *)stringByTrimmingWhitespaces;

/**
 * Returns NO if the string is empty or only made of whitespaces
 */
- (BOOL)isFilled;

/**
 * URL encoded (aka percent encoded) string with RFC 3986 compliance
 * See http://www.openradar.me/6546984
 */
- (NSString *)urlEncodedStringUsingEncoding:(NSStringEncoding)encoding;

/**
 * Calculates the MD2 hash of a string (hexadecimal)
 */
- (NSString *)md2hash;

/**
 * Calculates the MD4 hash of a string (hexadecimal)
 */
- (NSString *)md4hash;

/**
 * Calculates the MD5 hash of a string (hexadecimal)
 */
- (NSString *)md5hash;

/**
 * Calculates the SHA-1 hash of a string (hexadecimal)
 */
- (NSString *)sha1hash;

/**
 * Calculates the SHA-224 hash of a string (hexadecimal)
 */
- (NSString *)sha224hash;

/**
 * Calculates the SHA-256 hash of a string (hexadecimal)
 */
- (NSString *)sha256hash;

/**
 * Calculates the SHA-384 hash of a string (hexadecimal)
 */
- (NSString *)sha384hash;

/**
 * Calculates the SHA-512 hash of a string (hexadecimal)
 */
- (NSString *)sha512hash;

/**
 * At Hortis, we use a convenient way to identify versions during development, for tags and for official releases:
 *   - For all versions except AppStore releases:         [lastVersionNumber+]versionNumber[+qualifier]
 *   - For AppStore releases:                             versionNumber
 * where:
 *   - lastVersionNumber is the most recent tagged version (if any)
 *   - versionNumber is a version number. We use several formats:
 *       x.x[.x[.x]]            represents "standard" versions
 *       x.x[.x[.x]]+bN         represents the N-th beta for version x.x[.x[.x]]
 *       x.x[.x[.x]]+rcN        represents the N-th release candidate for version x.x[.x[.x]]
 *     This ordering works because it matches the alphabetical ordering.
 *   - qualifier is either:
 *       dev                    for development versions (trunk). This qualifier is never to be used for tags
 *       test                   for tagged versions used with test environments (e.g. test servers)
 * Examples are:
 *   0.8                        version 0.8
 *   0.8+dev                    trunk, last tagged version was 0.8
 *   0.9+1.0b1                  first beta for version 1.0, last tagged version was 0.9
 *   0.9+1.0b1+dev              trunk, last tagged version was 0.9+1.0b1
 *   0.9+1.0rc2                 second release candidate for version 1.0, last taggged version was 0.9
 *   1.0                        version 1.0; this might for example be an AppStore release
 *   1.0+test                   test version 1.0
 *
 * This convention is well suited for version number ordering with the AppStore and iTunes, but can be difficult
 * to understand for users. The following method is used to convert a string into the corresponding user-friendly 
 * version number:
 *   - for versions with dev or test qualifier, return the full version number
 *   - for versions without qualifier, only returns the version number (only the rightmost version number).
 * In the examples above, we get respectively:
 *   0.8
 *   0.8+dev
 *   1.0b1
 *   0.9+1.0b1+dev
 *   1.0rc2
 *   1.0
 *   1.0+test
 */
- (NSString *)friendlyVersionNumber;

@end
