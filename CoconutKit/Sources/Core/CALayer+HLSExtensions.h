//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (HLSExtensions)

/**
 * This method removes all animations added to a CALayer and to all layers in its sublayer hierarchy
 * (the usual -removeAllAnimations only removes the animations attached to a layer, not to its sublayers)
 */
- (void)hls_removeAllAnimationsRecursively;

/**
 * Pause all animations attached to a layer. Does nothing if the layer was already paused
 */
- (void)hls_pauseAllAnimations;

/**
 * Resume animations attached to a layer. Does nothing if the layer was not paused
 */
- (void)hls_resumeAllAnimations;

/**
 * Return YES iff layer animations have been paused
 */
@property (nonatomic, readonly, getter=hls_isPaused) BOOL hls_paused;

/**
 * Return the layer and all its sublayers flattened as a UIImage
 */
@property (nonatomic, readonly) UIImage *hls_flattenedImage;

@end

NS_ASSUME_NONNULL_END
