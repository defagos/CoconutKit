//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Thin wrapper to provide for store weak references in associated objects (see HLSRuntime.m)
 *
 * Borrowed from http://stackoverflow.com/questions/16569840/using-objc-setassociatedobject-with-weak-references/27035233#27035233
 */
@interface HLSWeakObjectWrapper : NSObject

- (instancetype)initWithObject:(nullable id)object NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, weak, nullable) id object;

@end

NS_ASSUME_NONNULL_END
