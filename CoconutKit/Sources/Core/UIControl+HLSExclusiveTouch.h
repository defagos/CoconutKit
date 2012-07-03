//
//  UIControl+HLSExclusiveTouch.h
//  CoconutKit
//
//  Created by Samuel Défago on 07.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Globally sets exclusiveTouch for all UIControl objects, preventing quasi-simultaneous taps.
 */
@interface UIControl (HLSExclusiveTouch)

/**
 * Call this method as soon as possible if you want to disable quasi-simultaneous taps for your whole application. For 
 * simplicity you should use the HLSEnableUIControlInjection convenience macro instead (see HLSOptionalFeatures.h)
 */
+ (void)injectExclusiveTouch;

@end
