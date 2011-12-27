//
//  NSError+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface NSError (HLSExtensions)

/**
 * Return the errors embedded into th
 */
- (NSArray *)errors;

/**
 * Return the user-specific information (i.e. without the information corresponding to reserved keys)
 */
- (NSDictionary *)customUserInfo;

/**
 * Return YES iff the receiver and error have the same domain and code
 */
- (BOOL)isEqualToError:(NSError *)error;

@end
