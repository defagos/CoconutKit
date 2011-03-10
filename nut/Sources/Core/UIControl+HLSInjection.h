//
//  UIControl+HLSInjection.h
//  nut
//
//  Created by Samuel Défago on 3/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope, e.g. outside your main function in main.m to enable 
 * or in your application delegate implementation file
 */
#define HLSEnableUIControlInjection()                                                               \
    __attribute__ ((constructor)) void UIControlInjectionConstructor(void)                          \
    {                                                                                               \
        [UIControl injectQuasiSimultaneousTapsDisabler];                                            \
    }

/** 
 * In UIKit, nothing prevents quasi-simulatenous taps on several buttons. Such taps can lead to very annoying issues.
 * For example, if two buttons opening two different view controllers modally are clicked quasi simultaenously, and 
 * if both of them respond to a touch up event to show their respective view controller, then you might end up stacking 
 * two view controllers modally. In such cases, your intention was of course to always present one modal view controller 
 * at a time.
 *
 * In general, you can fix such issues by littering your code with boolean variables and testing them in each button
 * action method. This is ugly, error-prone and painful.
 *
 * To avoid such issues, the category below allows to globally inject some code to disable quasi-simulatenous taps. If such 
 * taps occur, only the first one will be executed, not the other ones. Double taps on the same control are of course not 
 * affected, since they are simultaneous, not quasi.
 *
 * This code injects methods directly into UIControl. IMHO, you never want quasi simultaneous taps to occur, no matter
 * which control you use. Either you handle gestures involving several fingers for real simultaneous taps, or you
 * respond to single actions. Simultaneous taps are of no real use since the time between taps (which would define
 * what we mean by "quasi-simultaneous" is undefined).
 */ 
@interface UIControl (HLSInjection)

/**
 * Call this method as soon as possible if you want to benefit from injection. To achieve this easily, use the
 * UIControlInjectionConstructor convenience macro
 */
+ (void)injectQuasiSimultaneousTapsDisabler;

@end
