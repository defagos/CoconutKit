//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSLayerAnimation.h"
#import "HLSVector.h"

@import CoreGraphics;
@import Foundation;
@import QuartzCore;

NS_ASSUME_NONNULL_BEGIN

/**
  * Interface meant to be used by friend classes of HLSLayerAnimation (= classes which must have access to private implementation
  * details)
  */
@interface HLSLayerAnimation (Friend)

/**
 * The transform corresponding to the view animation settings
 */
@property (nonatomic, readonly) CATransform3D transform;

/**
 * The sublayer transform corresponding to the view animation settings
 */
@property (nonatomic, readonly) CATransform3D sublayerTransform;

/**
 * The z-translation to apply to the camera from which sublayers are seen
 */
@property (nonatomic, readonly) CGFloat sublayerCameraTranslationZ;

/**
 * The translation to apply to the layer anchor point
 */
@property (nonatomic, readonly) HLSVector3 anchorPointTranslationParameters;

/**
 * The increment to apply to the layer opacity value
 */
@property (nonatomic, readonly) CGFloat opacityIncrement;

/**
 * The increment to apply to the layer rasterization scale
 */
@property (nonatomic, readonly) CGFloat rasterizationScaleIncrement;

@end

NS_ASSUME_NONNULL_END
