//
//  HLSLayerAnimation+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/2/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
  * Interface meant to be used by friend classes of HLSLayerAnimation (= classes which must have access to private implementation
  * details)
  */
@interface HLSLayerAnimation (Friend)

/**
 * The transform corresponding to the view animation settings
 */
@property (nonatomic, readonly, assign) CATransform3D transform;

/**
 * The sublayer transform corresponding to the view animation settings
 */
@property (nonatomic, readonly, assign) CATransform3D sublayerTransform;

/**
 * The z-translation to apply to the camera from which sublayers are seen
 */
@property (nonatomic, readonly, assign) CGFloat sublayerCameraTranslationZ;

/**
 * The translation to apply to the layer anchor point
 */
@property (nonatomic, readonly, assign) HLSVector3 anchorPointTranslationParameters;

/**
 * The increment to apply to the layer opacity value
 */
@property (nonatomic, readonly, assign) CGFloat opacityIncrement;

/**
 * The increment to apply to the layer rasterization scale
 */
@property (nonatomic, readonly, assign) CGFloat rasterizationScaleIncrement;

@end
