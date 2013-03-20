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
 * Return a color by name. By convention, all class methods ending with 'Color' and returning a UIColor
 * object are assumed to be colors and can be instantiated by name (i.e. if you want to instantiate blue,
 * calling [UIColor colorWithName:@"blue"] is equivalent to calling [UIColor blueColor]. If the color 
 * does not exist or if the given name does not correspond to a valid color, the method returns nil
 *
 * When looking up a color, the class onto which -colorWithName: is called, as well as all its superclasses
 * and categories, are considered.
 *
 * For convenience, colors can be set by name directly in Interface Builder. This lets you define a custom
 * set of colors in code (e.g. corporate colors), which you can then conveniently and consistently use in Interface
 * Builder. The actual result cannot be directly seen on screen, of course, but this helps you skin your
 * applications in such a way that skinning is consistent and easy to update. 
 *
 * This mechanism is implemented for the whole UIView class hierarchy, as follows: For any UIView subclass, 
 * all writable KVC-compliant color property someColor has been added a corresponding hlsSomeColor property
 * you can set as user-defined runtime string attribute. Set the color to use by assigning a value of the
 * form 'colorClassName:colorName', where colorClassName is the name of the class on which the color is
 * defined, and colorName is the color name. The shorter syntax 'colorName' can also be used, in which case
 * lookup will be performed on UIColor.
 *
 * For example, if you have defined a color +[UIColor(SomeCategory) corporateColor], you can set the text
 * color of a UILabel by adding a user-defined runtime attribute called 'hlsTextColor', setting its value
 * to 'corporate'. If the color is defined on a UIColor subclass, say +[SomeColor corporate] color, then
 * set the 'hlsTextColor' value to 'SomeColor:corporate'
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
