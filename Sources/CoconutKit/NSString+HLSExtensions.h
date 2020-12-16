//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

// Formatting functions
OBJC_EXPORT NSString *HLSStringFromCATransform3D(CATransform3D transform);

@interface NSString (HLSExtensions)

/**
 * Trim spaces left and right
 */
@property (nonatomic, readonly, copy) NSString *stringByTrimmingWhitespaces;

/**
 * Return NO if the string is empty or only made of whitespaces
 */
@property (nonatomic, readonly, getter=isFilled) BOOL filled;

/**
 * Calculate the MD2 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *md2hash;

/**
 * Calculate the MD4 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *md4hash;

/**
 * Calculate the MD5 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *md5hash;

/**
 * Calculate the SHA-1 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *sha1hash;

/**
 * Calculate the SHA-224 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *sha224hash;

/**
 * Calculate the SHA-256 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *sha256hash;

/**
 * Calculate the SHA-384 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *sha384hash;

/**
 * Calculate the SHA-512 hash of a string (hexadecimal)
 */
@property (nonatomic, readonly, copy) NSString *sha512hash;

/**
 * Here is a convenient way to identify versions during development, for tags and for official releases:
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
@property (nonatomic, readonly, copy, nullable) NSString *friendlyVersionNumber;

/**
 * Guess the MIME type from the path extension
 */
@property (nonatomic, readonly, copy, nullable) NSString *MIMEType;

@end

NS_ASSUME_NONNULL_END
