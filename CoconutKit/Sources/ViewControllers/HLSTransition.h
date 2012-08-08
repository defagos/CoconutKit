//
//  HLSTransitions.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/8/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimation.h"

#if 0

typedef enum {
    HLSTransitionStyleEnumBegin = 0,
    HLSTransitionStyleNone = HLSTransitionStyleEnumBegin,    // No transtion
    HLSTransitionStyleCoverFromBottom,                       // The new view covers the old one starting from the bottom
    HLSTransitionStyleCoverFromTop,                          // The new view covers the old one starting from the top
    HLSTransitionStyleCoverFromLeft,                         // The new view covers the old one starting from the left
    HLSTransitionStyleCoverFromRight,                        // The new view covers the old one starting from the right
    HLSTransitionStyleCoverFromTopLeft,                      // The new view covers the old one starting from the top left corner
    HLSTransitionStyleCoverFromTopRight,                     // The new view covers the old one starting from the top right corner
    HLSTransitionStyleCoverFromBottomLeft,                   // The new view covers the old one starting from the bottom left corner
    HLSTransitionStyleCoverFromBottomRight,                  // The new view covers the old one starting from the bottom right corner
    HLSTransitionStyleCoverFromBottom2,                      // The new view covers the old one starting from the bottom
    HLSTransitionStyleCoverFromTop2,                         // The new view covers the old one starting from the top (the old view is pushed to the back)
    HLSTransitionStyleCoverFromLeft2,                        // The new view covers the old one starting from the left (the old view is pushed to the back)
    HLSTransitionStyleCoverFromRight2,                       // The new view covers the old one starting from the right (the old view is pushed to the back)
    HLSTransitionStyleCoverFromTopLeft2,                     // The new view covers the old one starting from the top left corner (the old view is pushed to the back)
    HLSTransitionStyleCoverFromTopRight2,                    // The new view covers the old one starting from the top right corner (the old view is pushed to the back)
    HLSTransitionStyleCoverFromBottomLeft2,                  // The new view covers the old one starting from the bottom left corner (the old view is pushed to the back)
    HLSTransitionStyleCoverFromBottomRight2,                 // The new view covers the old one starting from the bottom right corner (the old view is pushed to the back)
    HLSTransitionStyleFadeIn,                                // The new view fades in, the old one does not change
    HLSTransitionStyleFadeIn2,                               // The new view fades in, the old one is pushed to the back
    HLSTransitionStyleCrossDissolve,                         // The old view fades out and disappears as the new one fades in
    HLSTransitionStylePushFromBottom,                        // The new view pushes up the old one (which disappears)
    HLSTransitionStylePushFromTop,                           // The new view pushes down the old one (which disappears)
    HLSTransitionStylePushFromLeft,                          // The new view pushes the old one to the right (which disappears)
    HLSTransitionStylePushFromRight,                         // The new view pushes the old one to the left (which disappears)
    HLSTransitionStylePushFromBottomFadeIn,                  // The old view is pushed from the bottom, then the new one appears with a fade in animation
    HLSTransitionStylePushFromTopFadeIn,                     // The old view is pushed from the top, then the new one appears with a fade in animation
    HLSTransitionStylePushFromLeftFadeIn,                    // The old view is pushed from the left, then the new one appears with a fade in animation
    HLSTransitionStylePushFromRightFadeIn,                   // The old view is pushed from the right, then the new one appears with a fade in animation
    HLSTransitionStyleFlowFromBottom,                        // The old view is pushed to the back, pushed from the bottom by the new one, which then is then pushed to the front
    HLSTransitionStyleFlowFromTop,                           // The old view is pushed to the back, pushed from the top by the new one, which then is then pushed to the front
    HLSTransitionStyleFlowFromLeft,                          // The old view is pushed to the back, pushed from the left by the new one, which then is then pushed to the front
    HLSTransitionStyleFlowFromRight,                         // The old view is pushed to the back, pushed from the right by the new one, which then is then pushed to the front
    HLSTransitionStyleEmergeFromCenter,                      // The new view emerges from the center of the placeholder view
    HLSTransitionStyleFlipVertical,                          // The new view appears with a vertical 3D flip
    HLSTransitionStyleFlipHorizontal,                        // The new view appears with a horizontal 3D flip
    HLSTransitionStyleEnumEnd,
    HLSTransitionStyleEnumSize = HLSTransitionStyleEnumEnd - HLSTransitionStyleEnumBegin
} HLSTransitionStyle;

#endif

// Default duration for a transition animation. This is a reserved value and does not correspond to any meaningful
// duration
extern const NSTimeInterval kAnimationTransitionDefaultDuration;

@interface HLSTransition : NSObject

// TODO: Define string identifier constants here for built-in types

/**
 * Returns an array of string identifiers for the available transitions
 * TODO: Use runtime.h to find all subclasses
 */
+ (NSArray *)availableTransitions;

/**
 * Subclasses must override this method
 * TODO: When called, must ensure that appearing and disappearing views belong to the
 *       view
 */
+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame;

@end

/**
 * Standard transitions
 */
@interface HLSTransitionNone : HLSTransition
@end

@interface HLSTransitionCoverFromBottom : HLSTransition
@end

@interface HLSTransitionCoverFromTop : HLSTransition
@end

@interface HLSTransitionCoverFromLeft : HLSTransition
@end

@interface HLSTransitionCoverFromRight : HLSTransition
@end

@interface HLSTransitionCoverFromTopLeft : HLSTransition
@end

@interface HLSTransitionCoverFromTopRight : HLSTransition
@end

@interface HLSTransitionCoverFromBottomLeft : HLSTransition
@end

@interface HLSTransitionCoverFromBottomRight : HLSTransition
@end

@interface HLSTransitionCoverFromBottom2 : HLSTransition
@end

@interface HLSTransitionCoverFromTop2 : HLSTransition
@end

@interface HLSTransitionCoverFromLeft2 : HLSTransition
@end

@interface HLSTransitionCoverFromRight2 : HLSTransition
@end

@interface HLSTransitionCoverFromTopLeft2 : HLSTransition
@end

@interface HLSTransitionCoverFromTopRight2 : HLSTransition
@end

@interface HLSTransitionCoverFromBottomLeft2 : HLSTransition
@end

@interface HLSTransitionFadeIn : HLSTransition
@end

@interface HLSTransitionFadeIn2 : HLSTransition
@end

@interface HLSTransitionCrossDissolve : HLSTransition
@end

@interface HLSTransitionPushFromBottom : HLSTransition
@end

@interface HLSTransitionPushFromTop : HLSTransition
@end

@interface HLSTransitionPushFromLeft : HLSTransition
@end

@interface HLSTransitionPushFromRight : HLSTransition
@end

@interface HLSTransitionPushFromBottomFadeIn : HLSTransition
@end

@interface HLSTransitionPushFromTopFadeIn : HLSTransition
@end

@interface HLSTransitionPushFromLeftFadeIn : HLSTransition
@end

@interface HLSTransitionPushFromRightFadeIn : HLSTransition
@end

@interface HLSTransitionFlowFromBottom : HLSTransition
@end

@interface HLSTransitionFlowFromTop : HLSTransition
@end

@interface HLSTransitionFlowFromLeft : HLSTransition
@end

@interface HLSTransitionFlowFromRight : HLSTransition
@end

@interface HLSTransitionEmergeFromCenter : HLSTransition
@end

@interface HLSTransitionFlipVertical : HLSTransition
@end

@interface HLSTransitionFlipHorizontal : HLSTransition
@end
