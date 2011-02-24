//
//  NSString+HLSExtensions.h
//  nut
//
//  Created by Samuel Défago on 11/3/10.
//  Copyright 2010 Hortis. All rights reserved.
//

@interface NSString (HLSExtensions)

/**
 * Calculates the MD5 hash of a string
 */
- (NSString *)md5hash;

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
*      This ordering matches because it matches the alphabetical ordering.
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
