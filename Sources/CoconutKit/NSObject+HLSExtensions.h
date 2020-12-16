//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HLSExtensions)

/**
 * Return the name of a class as a string
 */
+ (NSString *)className;

/**
 * Return the name of an object's class (as returned by [self class]) as a string. May be faked by dynamic subclasses
 * (e.g. those added by KVO)
 */
@property (nonatomic, readonly, copy) NSString *className;

/**
 * Return YES iff the object class implements all methods of a given protocol
 */
- (BOOL)implementsProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
