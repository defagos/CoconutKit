//
//  UIControl+HLSInjection.h
//  nut
//
//  Created by Samuel Défago on 3/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable the UIControl injection early, disabling quasi-
 * simultaneous taps. Good places are for example main.m or your application delegate .m file
 */
#define HLSEnableUIControlInjection()                                                               \
    __attribute__ ((constructor)) void UIControlInjectionConstructor(void)                          \
    {                                                                                               \
        [UIControl injectQuasiSimultaneousTapsDisabler];                                            \
    }

/** 
 * With UIKit, nothing prevents quasi-simulatenous taps on different controls. Such taps can lead to very annoying issues.
 * For example, if two buttons opening two different modal view controllers are clicked quasi simultaneously, and 
 * if both of them show their respective view controllers on touch up, then you might end up stacking two view controllers 
 * modally.
 *
 * In general, you can fix such issues by littering your code with boolean variables and testing them in each control
 * action method. This is ugly, error-prone and rather painful.
 *
 * To avoid this, the category below allows to globally inject code disabling quasi-simulatenous taps. If such 
 * taps occur, only the first one will be executed, not the other ones which are inhibited temporarily. Note that the 
 * inhibited controls can still be highlighted when tapped, but that the associated events are in fact disabled.
 *
 * This category injects methods directly into UIControl. IMHO, you never want quasi simultaneous taps to occur, no matter
 * which control you use. Your either want to handle gestures involving several fingers for real simultaneous taps, or you
 * respond to single actions involving one control only.
 */ 
@interface UIControl (HLSInjection)

/**
 * Call this method as soon as possible if you want to disable quasi-simultaneous taps for your whole application. For 
 * simplicity you should use the UIControlInjectionConstructor convenience macro instead
 */
+ (void)injectQuasiSimultaneousTapsDisabler;

@end
