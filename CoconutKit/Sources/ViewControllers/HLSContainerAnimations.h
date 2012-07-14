//
//  HLSContainerAnimations.h
//  CoconutKit
//
//  Created by Samuel Défago on 13.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerContent.h"
#import "HLSTransitionStyle.h"

// TODO: To fix issues with flip animations, after an animation ends fix subview ordering to match the one of container
//       contents

/**
 * Private class implementing animations for containers
 */
@interface HLSContainerAnimations : NSObject

/**
 * Return the animation which makes a view controller appear, and other ones disappear. The view controllers
 * to make appear or disappear might be nil, this is why the transition style to apply has to be provided
 * separately
 */
+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView
                                      duration:(NSTimeInterval)duration;

/**
 * Return the animation which has to be played when a set of view controllers need to be rotated
 */
+ (HLSAnimation *)rotationAnimationWithContainerContents:(NSArray *)containerContents
                                           containerView:(UIView *)containerView
                                                duration:(NSTimeInterval)duration;

@end
