//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (HLSExtensions)

/**
 * This method removes all animations added to a CALayer and to all layers in its sublayer hierarchy
 * (the usual -removeAllAnimations only removes the animations attached to a layer, not to its sublayers)
 */
- (void)removeAllAnimationsRecursively;

/**
 * Pause all animations attached to a layer. Does nothing if the layer was already paused
 */
- (void)pauseAllAnimations;

/**
 * Resume animations attached to a layer. Does nothing if the layer was not paused
 */
- (void)resumeAllAnimations;

/**
 * Return YES iff layer animations have been paused
 */
- (BOOL)isPaused;

/**
 * Return the layer and all its sublayers flattened as a UIImage
 */
- (UIImage *)flattenedImage;

@end
