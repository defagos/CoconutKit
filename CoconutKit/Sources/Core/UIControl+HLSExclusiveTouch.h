//
//  UIControl+HLSExclusiveTouch.h
//  CoconutKit
//
//  Created by Samuel Défago on 07.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Globally set exclusive touch to YES for all UIControl objects, preventing quasi-simultaneous taps.
 */
@interface UIControl (HLSExclusiveTouch)

/**
 * Call this method as soon as possible if you want to prevent quasi-simultaneous taps for your whole application. For 
 * simplicity you should use the HLSEnableUIControlExclusiveTouch convenience macro instead (see HLSOptionalFeatures.h)
 */
+ (void)enable;

@end
