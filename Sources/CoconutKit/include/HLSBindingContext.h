//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface HLSBindingContext : NSObject

/**
 * The resolved object target for the key path which has been bound
 */
@property (nonatomic, readonly, weak, nullable) id objectTarget;

/**
 * The key path which has been bound
 */
@property (nonatomic, readonly, copy) NSString *keyPath;

/**
 * The value corresponding to the key path applied on the object target
 */
@property (nonatomic, readonly, nullable) id value;

/**
 * The last path component of the key path (might be prefixed with an operator)
 */
@property (nonatomic, readonly, copy) NSString *lastKeyPathComponent;

/**
 * The last object in the key path (before the final key path component is applied)
 */
@property (nonatomic, readonly, weak, nullable) id lastObjectTarget;

@end

@interface HLSBindingContext (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
