//
//  UIColor+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface UIColor (HLSExtensions)

/**
 * Create a color from non-normalized RGB components (i.e. from 0 to 255)
 */
+ (UIColor *)colorWithNonNormalizedeRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;

/**
 * Return a random color
 */
+ (UIColor *)randomColor;

/**
 * Return a color by name. By convention, all class methods ending with 'color' and returning a UIColor
 * object are assumed to be colors and can be instantiated by name (i.e. if you want to instantiate blue,
 * calling [UIColor colorWithName:@"blue"] is equivalent to calling [UIColor blueColor]. If the color 
 * does not exist, the method returns nil
 *
 * When looking up a color, the class onto which -colorWithName: is called, as well as all its superclasses,
 * are considered
 *
 * For convenience, you can also set colors by name directly in Interface Builder via user-defined runtime
 * attributes. Simply add an attribute called 'hlsColor', and set its value to 'colorClass:colorName', where
 * 'colorClass' is the name of the class where lookup must be performed, and 'colorName' is the color name.
 * You can set the attribute value to 'colorName' only, in which case lookup will be performed on UIColor
 * (this of course includes any category you might have defined)
 */
+ (UIColor *)colorWithName:(NSString *)name;

/**
 * Return the invert color corresponding to the receiver
 */
- (UIColor *)invertedColor;

/**
 * Return non-normalized color components (0 - 255)
 */
- (NSUInteger)redComponent;
- (NSUInteger)greenComponent;
- (NSUInteger)blueComponent;

/**
 * Return the normalized color components (0.f - 1.f)
 */
- (CGFloat)normalizedRedComponent;
- (CGFloat)normalizedGreenComponent;
- (CGFloat)normalizedBlueComponent;

@end
