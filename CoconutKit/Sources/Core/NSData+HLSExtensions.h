//
//  NSData+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSData (HLSExtensions)

/**
 * Return a data object decoded from a base 64 string
 */
+ (instancetype)dataWithBase64EncodedString:(NSString *)base64EncodedString;

/**
 * Return a data object decoded from base 64, UTF-8 data
 */
+ (instancetype)dataWithBase64EncodedData:(NSData *)base64EncodedData;

/**
 * Create an NSData decoded from a base 64 encoded string
 */
- (id)initWithBase64EncodedString:(NSString *)base64String;

/**
 * Create an NSData decoded from base 64, UTF-8 encoded data
 */
- (id)initWithBase64EncodedData:(NSData *)base64Data;

/**
 * Return the data as a base 64 encoded string
 */
- (NSString *)base64EncodedString;

/**
 * Return the data encoded in base 64, UTF-8
 */
- (NSData *)base64EncodedData;

/**
 * Calculates the MD2 hash
 */
- (NSString *)md2hash;

/**
 * Calculates the MD4 hash
 */
- (NSString *)md4hash;

/**
 * Calculates the MD5 hash
 */
- (NSString *)md5hash;

/**
 * Calculates the SHA-1 hash
 */
- (NSString *)sha1hash;

/**
 * Calculates the SHA-224 hash
 */
- (NSString *)sha224hash;

/**
 * Calculates the SHA-256 hash
 */
- (NSString *)sha256hash;

/**
 * Calculates the SHA-384 hash
 */
- (NSString *)sha384hash;

/**
 * Calculates the SHA-512 hash
 */
- (NSString *)sha512hash;

@end
