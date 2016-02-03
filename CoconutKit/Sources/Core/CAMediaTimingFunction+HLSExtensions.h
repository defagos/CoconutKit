//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CAMediaTimingFunction (HLSExtensions)

/**
 * Evaluate the function for a given time in [0; 1]. Parameters outside this range are clamped to the nearest
 * valid value
 *
 * Remark: A private method exists on CAMediaTimingFunction. The results returned by -valueForNormalizedTime:
 *         are in excellent agreement with the ones returned by this private method
 */
- (float)valueForNormalizedTime:(float)time;

/**
 * Return the inverse function, i.e. the one which must be played when playing an animation backwards
 */
- (CAMediaTimingFunction *)inverseFunction;

/**
 * Return the control points as a human-readable string
 */
- (NSString *)controlPointsString;

@end
