//
//  CALayer+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface CALayer (HLSExtensions)

/**
 * This method removes all animations added to a CALayer and to all layers in its sublayer hierarchy
 * (the usual removeAllAnimations only remove the animations attached to a layer, not to its sublayers)
 */
- (void)removeAllAnimationsRecursively;

- (void)togglePauseAllAnimations;

- (BOOL)areAllAnimationsPaused;

- (void)resetAnimations;

@end
