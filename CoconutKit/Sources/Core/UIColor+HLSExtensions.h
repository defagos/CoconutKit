//
//  UIColor+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface UIColor (HLSExtensions)

/**
 * Return a random color
 */
+ (UIColor *)randomColor;

/**
 * Return the ivert color corresponding to the receiver
 */
- (UIColor *)invertColor;

@end
