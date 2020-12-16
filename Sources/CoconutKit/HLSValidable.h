//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A protocol for objects supporting validation
 */
@protocol HLSValidable <NSObject>
@required

/**
 * Must return YES iff validation is succesful
 */
- (BOOL)validate;

@end

NS_ASSUME_NONNULL_END
