//
//  HLSStackPushSegue.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSTransitionStyle.h"

/**
 * Segue class for pushing view controllers into an HLSStackController when using storyboards. The source
 * view controller can implement the -prepareForSegue:sender: method to further customize transition
 * properties (transition style and duration)
 *
 * Each HLSStackController dropped onto a storyboard must be connected to its root view controller using
 * a segue with the identifier 'root'. To push a view controller B onto another one A already in the stack, 
 * connect A with B using a HLSStackPushSegue
 */
@interface HLSStackPushSegue : UIStoryboardSegue {
@private
    HLSTransitionStyle m_transitionStyle;
    NSTimeInterval m_duration;
}

/**
 * Push animation style
 * Default value is HLSTransitionStyleNone
 */
@property (nonatomic, assign) HLSTransitionStyle transitionStyle;

/**
 * Push animation duration
 * Default is kAnimationTransitionDefaultDuration
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
