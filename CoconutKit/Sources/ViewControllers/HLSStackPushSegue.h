//
//  HLSStackPushSegue.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSTransition.h"

/**
 * The segue identifier reserved for setting the root view controller of a stack ('hls_root')
 */
extern NSString * const HLSStackRootSegueIdentifier;

/**
 * Segue class for pushing view controllers into an HLSStackController when using storyboards. The source
 * view controller can implement the -prepareForSegue:sender: method to further customize transition
 * properties
 *
 * Each HLSStackController dropped onto a storyboard must be connected to its root view controller using
 * a segue with the identifier 'hls_root'. To push a view controller B onto another one A already in the 
 * stack, connect A with B using an HLSStackPushSegue
 */
@interface HLSStackPushSegue : UIStoryboardSegue {
@private
    Class m_transitionClass;
    NSTimeInterval m_duration;
    BOOL m_animated;
}

/**
 * Push animation style
 * Default value is HLSTransitionNone
 */
@property (nonatomic, assign) Class transitionClass;

/**
 * Push animation duration
 * Default is kAnimationTransitionDefaultDuration
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * Animated transition
 * Default is YES
 */
@property (nonatomic, assign) BOOL animated;

@end
