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

@end
