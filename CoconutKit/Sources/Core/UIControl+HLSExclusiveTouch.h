//
//  UIControl+HLSExclusiveTouch.h
//  CoconutKit
//
//  Created by Samuel Défago on 07.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable the UIControl injection early, disabling quasi-
 * simultaneous taps. Good places are for example main.m or your application delegate .m file
 */
#define HLSEnableUIControlExclusiveTouch()                                                                \
    __attribute__ ((constructor)) void HLSEnableUIControlExclusiveTouchConstructor(void)                  \
    {                                                                                                     \
        [UIControl injectExclusiveTouch];                                                                 \
    }

/**
 * Globally sets exclusiveTouch for all UIControl objects, preventing quasi-simultaneous taps.
 */
@interface UIControl (HLSExclusiveTouch)

/**
 * Call this method as soon as possible if you want to disable quasi-simultaneous taps for your whole application. For 
 * simplicity you should use the HLSEnableUIControlInjection convenience macro instead
 */
+ (void)injectExclusiveTouch;

@end
