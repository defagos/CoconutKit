//
//  CAMediaTimingFunction+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface CAMediaTimingFunction (HLSExtensions)

/**
 * Evaluate the function for a given time in [0; 1]. Parameters outside this range are clamped to the nearest
 * valid value
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
