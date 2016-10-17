//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewAnimation.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface meant to be used by friend classes of HLSViewAnimation (= classes which must have access to private implementation
 * details)
 */
@interface HLSViewAnimation (Friend)

/**
 * The transform corresponding to the view animation settings
 */
@property (nonatomic, readonly) CGAffineTransform transform;

/**
 * The increment to apply to the view alpha value
 */
@property (nonatomic, readonly) CGFloat alphaIncrement;

@end

NS_ASSUME_NONNULL_END
