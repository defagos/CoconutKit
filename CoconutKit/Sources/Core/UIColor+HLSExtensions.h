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
+ (UIColor *)colorWithNonNormalizedRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;

/**
 * Return a random color
 */
+ (UIColor *)randomColor;

/**
 * Return a color by name. By convention, all class methods ending with 'Color' and returning a UIColor
 * object can be instantiated by name. The corresponding color names are obtained by simply removing 
 * the 'Color' suffix from those method names.
 *
 * For example, you usually instantiate the blue color by calling [UIColor blueColor]. This class method
 * conforms to the above requirements, you can therefore call [UIColor colorWithName:@"blue"] instead
 * and get the exact same color.
 *
 * When looking up a color by name, the class onto which +colorWithName: is called as well as all its
 * superclasses and categories are considered. If the color does not exist or if the given name does 
 * not correspond to a valid color, the method returns nil.
 *
 * For convenience, colors can also be set by name directly in Interface Builder via user-defined runtime
 * attributes. This lets you define a custom set of colors in code (e.g. corporate colors), which you can 
 * then conveniently and consistently retrieve in Interface Builder by name. The actual result cannot be 
 * directly seen within Interface Builder, of course, but this helps you skin your applications so that
 * different color sets can be easily applied. This makes it easy to apply several different skinnings
 * to an application, without binding any outlet.
 *
 * This mechanism is implemented for the whole UIView class hierarchy, and as follows: For all UIView subclasses,
 * each writable KVC-compliant color setter of the form -setSomeNameColor: is associated with a corresponding
 * setter -setHlsSomeNameColor:, which can be set through user-defined runtime attributes. In other words, 
 * anywhere you set someNameColor, you can set an hlsSomeColorName attribute instead. For example, the 
 * backgroundColor property has an associated hlsBackgroundColor attribute, textColor has a corresponding 
 * hlsTextColor attribute, and so on. The color set using attributes will replace the one defined in the
 * nib (except if the color is not found, in which case the original color is kept).
 *
 * The values of these user-defined runtime attributes must be strings of the form 'colorClassName:colorName', 
 * where 'colorClassName' is the name of the class on which the color is defined, and 'colorName' is the color 
 * name. The shorter syntax 'colorName' can also be used, in which case lookup will be performed on UIColor
 * and associated categories.
 *
 * For example, if you have defined a color +[UIColor(SomeCategory) corporateColor], you can set the text
 * color of a UILabel by adding a user-defined runtime attribute called 'hlsTextColor', setting its value
 * to 'corporate'. If the color is defined on a UIColor subclass, say +[SomeColor corporateColor] color, 
 * then set the 'hlsTextColor' value to 'SomeColor:corporate'
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
