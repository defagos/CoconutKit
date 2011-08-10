//
//  NSData+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSData (HLSExtensions)

/**
 * Calculates the MD2 hash
 */
- (NSData *)md2hash;

/**
 * Calculates the MD4 hash
 */
- (NSData *)md4hash;

/**
 * Calculates the MD5 hash
 */
- (NSData *)md5hash;

/**
 * Calculates the SHA-1 hash
 */
- (NSData *)sha1hash;

/**
 * Calculates the SHA-224 hash
 */
- (NSData *)sha224hash;

/**
 * Calculates the SHA-256 hash
 */
- (NSData *)sha256hash;

/**
 * Calculates the SHA-384 hash
 */
- (NSData *)sha384hash;

/**
 * Calculates the SHA-512 hash
 */
- (NSData *)sha512hash;

@end
