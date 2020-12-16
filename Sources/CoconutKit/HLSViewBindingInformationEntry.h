//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains information related to a binding entry
 */
@interface HLSViewBindingInformationEntry : NSObject

/**
 * Create an entry with a given name (mandatory), text and object (optional). If an object is passed it will
 * be used to generated a description text, otherwise the specified text will be used
 */
- (instancetype)initWithName:(NSString *)name text:(nullable NSString *)text object:(nullable id)object NS_DESIGNATED_INITIALIZER;

/**
 * Convenience initializers
 */
- (instancetype)initWithName:(NSString *)name text:(nullable NSString *)text;
- (instancetype)initWithName:(NSString *)name object:(nullable id)object;

/**
 * Properties
 */
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy, nullable) NSString *text;
@property (nonatomic, readonly, nullable) id object;

/**
 * Return a view if there is a view associated with the entry, nil if none
 */
@property (nonatomic, readonly, nullable) UIView *view;

@end

@interface HLSViewBindingInformationEntry (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
