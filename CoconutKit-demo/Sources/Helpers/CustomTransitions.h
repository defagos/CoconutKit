//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/**
 * The following are custom transition examples showing how you can subclass HLSTransition to define your own animations
 */

/**
 * Transition: The appearing view falls from the top and bounces once at the bottom on top of the disappearing view,
 *             which is left as is
 * Reverse transition: The disappearing view slides to the top, revealing the appearing view behind it
 */
@interface CustomTransitionFallFromTop : HLSTransition
@end

/**
 * Transition: Both views rotate around an axis while being temporarily moved to the back
 */
@interface CustomTransitionRotateVerticallyCounterclockwise : HLSTransition
@end

@interface CustomTransitionRotateVerticallyClockwise : HLSTransition
@end

@interface CustomTransitionRotateHorizontallyCounterclockwise : HLSTransition
@end

@interface CustomTransitionRotateHorizontallyClockwise : HLSTransition
@end

/**
 * Same as HLSTransitionFadeIn, but applying a blur effect on the view which gets covered
 */
@interface CustomTransitionFadeInBlur : HLSTransition
@end
