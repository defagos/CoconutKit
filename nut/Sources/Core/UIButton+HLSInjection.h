//
//  UIButton+HLSInjection.h
//  nut
//
//  Created by Samuel Défago on 3/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable the UIButton injection early, disabling quasi-
 * simultaneous taps. Good places are for example main.m or your application delegate .m file
 */
#define HLSEnableUIButtonInjection()                                                                \
    __attribute__ ((constructor)) void UIButtonInjectionConstructor(void)                           \
    {                                                                                               \
        [UIButton injectQuasiSimultaneousTapsDisabler];                                             \
    }

/** 
 * With UIKit, nothing prevents quasi-simulatenous taps on different buttons. Such taps can lead to very annoying issues.
 * For example, if two buttons opening two different modal view controllers are clicked quasi simultaneously, and 
 * if both of them show their respective view controllers on touch up, then you might end up stacking two view controllers 
 * modally.
 *
 * In general, you can fix such issues by littering your code with boolean variables and testing them in each button
 * action method. This is ugly, error-prone and rather painful.
 *
 * To avoid this, the category below allows to globally inject code disabling quasi-simulatenous taps. If such 
 * taps occur, only the first one will be executed, not the other ones which are inhibited temporarily. Note that the 
 * inhibited buttons can still be highlighted when tapped, but that the associated events are in fact disabled.
 *
 * This category injects methods into UIButton. Initially, code was injected in UIControl, but the injection trick
 * which is applied requires a control to generate UIControlEventTouchDown... and UIControlEventTouchUp... events,
 * which is the case for UIButtons but not for controls in general (e.g. a UITextField only sends touch down
 * events only, a UISwitch only touch up events, etc.)
 */ 
@interface UIButton (HLSInjection)

/**
 * Call this method as soon as possible if you want to disable quasi-simultaneous taps for your whole application. For 
 * simplicity you should use the HLSEnableUIButtonInjection convenience macro instead
 */
+ (void)injectQuasiSimultaneousTapsDisabler;

@end
