//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HLSExtensions)

/**
 * Calculates the MD2 hash
 */
@property (nonatomic, readonly, copy) NSString *md2hash;

/**
 * Calculates the MD4 hash
 */
@property (nonatomic, readonly, copy) NSString *md4hash;

/**
 * Calculates the MD5 hash
 */
@property (nonatomic, readonly, copy) NSString *md5hash;

/**
 * Calculates the SHA-1 hash
 */
@property (nonatomic, readonly, copy) NSString *sha1hash;

/**
 * Calculates the SHA-224 hash
 */
@property (nonatomic, readonly, copy) NSString *sha224hash;

/**
 * Calculates the SHA-256 hash
 */
@property (nonatomic, readonly, copy) NSString *sha256hash;

/**
 * Calculates the SHA-384 hash
 */
@property (nonatomic, readonly, copy) NSString *sha384hash;

/**
 * Calculates the SHA-512 hash
 */
@property (nonatomic, readonly, copy) NSString *sha512hash;

@end

NS_ASSUME_NONNULL_END
