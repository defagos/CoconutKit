//
//  HLSTransitionStyle.h
//  CoconutKit
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

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
    HLSTransitionStyleEmergeFromCenter,                      // The new view emerges from the center of the placeholder view
    HLSTransitionStyleFlipVertical,                          // The new view appears with a vertical 3D flip
    HLSTransitionStyleFlipHorizontal,                        // The new view appears with a horizontal 3D flip
    HLSTransitionStyleEnumEnd,
    HLSTransitionStyleEnumSize = HLSTransitionStyleEnumEnd - HLSTransitionStyleEnumBegin
} HLSTransitionStyle;

// Default duration for a transition animation. This is a reserved value and does not correspond to any meaningful
// duration
extern const NSTimeInterval kAnimationTransitionDefaultDuration;
