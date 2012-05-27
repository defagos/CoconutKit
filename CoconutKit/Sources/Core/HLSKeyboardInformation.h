//
//  HLSKeyboardInformation.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/17/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * This class makes keyboard properties accessible at any time in a convenient way. Just access the keyboardInformation 
 * object. If this object is not nil, then the keyboard is docked and visible (or soon will) and you can check its 
 * properties. The object is nil if the keyboard is floating (iPad) or invisible.
 *
 * Not meant to be instantiated directly. Simply use the keyboardInformation class method.
 */
@interface HLSKeyboardInformation : NSObject {
@private
    CGRect m_beginFrame;
    CGRect m_endFrame;
    NSTimeInterval m_animationDuration;
    UIViewAnimationCurve m_animationCurve;
}

/**
 * Return the keyboard information if docked and displayed (or about to be displayed), nil if the keyboard is not visible,
 * about to be hidden, or floating
 */
+ (HLSKeyboardInformation *)keyboardInformation;

/**
 * Start frame of the keyboard before it is displayed (in the window coordinate system). Refer to the 
 * UIKeyboardFrameBeginUserInfoKey documentation for how to translate this frame into a meaningful coordinate system
 */
@property (nonatomic, readonly, assign) CGRect beginFrame;

/**
 * Start frame of the keyboard after it is displayed (in the window coordinate system). This is the most interesting 
 * keyboard property since it lets you find which screen area the keyboard covers when displayed. Refer to the 
 * UIKeyboardFrameEndUserInfoKey documentation for how to translate this frame into a meaningful coordinate system
 */
@property (nonatomic, readonly, assign) CGRect endFrame;

/**
 * Duration of the animation showing the keyboard
 */
@property (nonatomic, readonly, assign) NSTimeInterval animationDuration;

/**
 * Curve of the animation showing the keyboard
 */
@property (nonatomic, readonly, assign) UIViewAnimationCurve animationCurve;

@end
