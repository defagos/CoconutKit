//
//  NSError+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface NSError (HLSExtensions)

/**
 * Return the nested error which has been set (if any)
 */
- (NSError *)underlyingError;

/**
 * Return the errors embedded into the error
 */
- (NSArray *)errors;

/**
 * Return the object set for a given key. The key can either be a reserved one (see NSError) or a custom
 * one. Instead of using this generic accessor to retrieve objects corresponding to reserved keys, use the
 * standard accessors provided by NSError and HLSError
 */
- (id)objectForKey:(NSString *)key;

/**
 * Return the user-specific information (i.e. without the information corresponding to reserved keys)
 */
- (NSDictionary *)customUserInfo;

/**
 * Return YES iff the receiver has the provided error domain and code
 */
- (BOOL)hasCode:(NSInteger)code withinDomain:(NSString *)domain;

@end
