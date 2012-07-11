//
//  HLSContainerAnimations.h
//  CoconutKit
//
//  Created by Samuel Défago on 13.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerContent.h"
#import "HLSTransitionStyle.h"

@interface HLSContainerAnimations : NSObject

+ (HLSAnimation *)pushAnimationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                         appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                     disappearingContainerContents:(NSArray *)disappearingContainerContents
                                     containerView:(UIView *)containerView
                                          duration:(NSTimeInterval)duration;

+ (HLSAnimation *)rotationAnimationWithContainerContents:(NSArray *)containerContents
                                           containerView:(UIView *)containerView
                                                duration:(NSTimeInterval)duration;

@end
