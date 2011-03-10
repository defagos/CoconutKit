//
//  UIControl+HLSInjection.h
//  nut
//
//  Created by Samuel Défago on 3/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable the UIControl injection early. Good places are
 * for example main.m or your application .m file
 */
#define HLSEnableUIControlInjection()                                                               \
    __attribute__ ((constructor)) void UIControlInjectionConstructor(void)                          \
    {                                                                                               \
        [UIControl injectQuasiSimultaneousTapsDisabler];                                            \
    }

/** 
 * With UIKit, nothing prevents quasi-simulatenous taps on several buttons. Such taps can lead to very annoying issues.
 * For example, if two buttons opening two different modal view controllers are clicked quasi simultaenously, and 
 * if both of them show their respective view controllers on touch up, then you might end up stacking two view controllers 
 * modally. In such cases, your intention was of course to always present one modal view controller at a time, and
 * not doing so could have all sort of nasty consequences (e.g. not being able to dismiss all stacked up view controllers, 
 * crashes, rickrolling, etc.)
 *
 * In general, you can fix such issues by littering your code with boolean variables and testing them in each button
 * action method. This is ugly, error-prone and rather painful.
 *
 * To avoid such issues, the category below allows to globally inject code disabling quasi-simulatenous taps. If such 
 * taps occur, only the first one will be executed, not the other ones which are inhibited temporarily. Double taps 
 * on the same control are of course not disabled, since they are simultaneous, not quasi. Note that the inhibited
 * controls can still be highlighted when tapped, but that the associated event are in fact disabled.
 *
 * This category injects methods directly into UIControl. IMHO, you never want quasi simultaneous taps to occur, no matter
 * which control you use. Your either want to handle gestures involving several fingers for real simultaneous taps, or you
 * respond to single actions involving one control only. Simultaneous taps are in fact undefined (which time interval
 * corresponds to quasi-simulatenous events?) and are therefore of no use.
 */ 
@interface UIControl (HLSInjection)

/**
 * Call this method as soon as possible if you want to benefit from injection. To achieve this easily, use the
 * UIControlInjectionConstructor convenience macro, which injects the code before the main function is entered
 */
+ (void)injectQuasiSimultaneousTapsDisabler;

@end
