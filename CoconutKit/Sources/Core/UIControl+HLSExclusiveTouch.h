//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Globally set exclusive touch to YES for all UIControl objects, preventing quasi-simultaneous taps.
 */
@interface UIControl (HLSExclusiveTouch)

/**
 * Call this method as soon as possible if you want to prevent quasi-simultaneous taps for your whole application. For 
 * simplicity you should use the HLSEnableUIControlExclusiveTouch convenience macro instead (see HLSOptionalFeatures.h)
 */
+ (void)enableExclusiveTouch;

@end
