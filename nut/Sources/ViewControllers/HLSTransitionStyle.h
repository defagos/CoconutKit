//
//  HLSTransitionStyle.h
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

typedef enum {
    HLSTransitionStyleEnumBegin = 0,
    HLSTransitionStyleNone = HLSTransitionStyleEnumBegin,                                       // No transtion
    HLSTransitionStyleCoverFromBottom,                                                          // The new view covers the old one starting from the bottom
    HLSTransitionStyleCoverFromTop,                                                             // The new view covers the old one starting from the top
    HLSTransitionStyleCoverFromLeft,                                                            // The new view covers the old one starting from the left
    HLSTransitionStyleCoverFromRight,                                                           // The new view covers the old one starting from the right
    HLSTransitionStyleCoverFromTopLeft,                                                         // The new view covers the old one starting from the top left corner
    HLSTransitionStyleCoverFromTopRight,                                                        // The new view covers the old one starting from the top right corner
    HLSTransitionStyleCoverFromBottomLeft,                                                      // The new view covers the old one starting from the bottom left corner
    HLSTransitionStyleCoverFromBottomRight,                                                     // The new view covers the old one starting from the bottom right corner
    HLSTransitionStyleFadeIn,                                                                   // The new view fades in, the old one does not change
    HLSTransitionStyleCrossDissolve,                                                            // The old view fades out as the new one fades in
    HLSTransitionStylePushFromBottom,                                                           // The new view pushes up the old one
    HLSTransitionStylePushFromTop,                                                              // The new view pushes down the old one
    HLSTransitionStylePushFromLeft,                                                             // The new view pushes the old one to the right
    HLSTransitionStylePushFromRight,                                                            // The new view pushes the old one to the left
    HLSTransitionStyleEmergeFromCenter,                                                         // The new view emerges from the center of the placeholder view
    HLSTransitionStyleEnumEnd,
    HLSTransitionStyleEnumSize = HLSTransitionStyleEnumEnd - HLSTransitionStyleEnumBegin
} HLSTransitionStyle;
