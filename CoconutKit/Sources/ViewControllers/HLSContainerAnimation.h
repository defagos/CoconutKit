//
//  HLSContainerAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 13.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSTransitionStyle.h"

/**
 * Private class implementing animations for containers
 */
@interface HLSContainerAnimation : NSObject

/**
 * Return the animation which make the two container content wrapper views appear and disappear using some
 * transition style and duration
 */
+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                                        inView:(UIView *)view
                                      duration:(NSTimeInterval)duration;

/**
 * Return the animation which has to be played when a set of view controllers need to be rotated
 */
+ (HLSAnimation *)rotationAnimationWithContainerContents:(NSArray *)containerContents
                                           containerView:(UIView *)containerView
                                                duration:(NSTimeInterval)duration;

@end
