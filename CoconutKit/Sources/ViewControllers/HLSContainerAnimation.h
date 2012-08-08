//
//  HLSContainerAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 13.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSTransitionStyle.h"

/**
 * Private class implementing animations for containers
 */
@interface HLSContainerAnimation : NSObject

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                                 appearingView:(UIView *)appearingView
                              disappearingView:(UIView *)disappearingView
                                        inView:(UIView *)view
                                      duration:(NSTimeInterval)duration;

/**
 * Return the animation which has to be played when a set of view controllers need to be rotated
 */
+ (HLSAnimation *)rotationAnimationWithContainerContents:(NSArray *)containerContents
                                           containerView:(UIView *)containerView
                                                duration:(NSTimeInterval)duration;

@end
