//
//  UIColor+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

@interface UIColor (HLSExtensions)

/**
 * Create a color from non-normalized RGB components (i.e. from 0 to 255)
 */
+ (instancetype)colorWithNonNormalizedRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;

/**
 * Return a random color
 */
+ (instancetype)randomColor;

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
 * each writable KVC-compliant color setter of the form -setPropertyColor: is provided with a corresponding
 * setter -setPropertyColorName:, which can be set through user-defined runtime attributes. In other words,
 * anywhere you set propertyColor, you can set the propertyColorName attribute instead. For example, the
 * backgroundColor property has an associated backgroundColorName attribute, textColor has a corresponding 
 * textColorName attribute, and so on. The color set using attributes will replace the one defined in the
 * nib (except if the color is not found, in which case the original color is kept). For convenience, most
 * UIKit views color attributes have been exposed through dedicated inspectable properties.
 *
 * The values of these user-defined runtime attributes must be strings of the form 'ColorClassName:colorName',
 * where 'ColorClassName' is the name of the class on which the color is defined, and 'ColorName' is the color
 * name. The shorter syntax 'ColorName' can also be used, in which case lookup will be performed on UIColor
 * and associated categories.
 *
 * For example, if you have defined a color +[UIColor(SomeCategory) corporateColor], you can set the text
 * color of a UILabel by adding a user-defined runtime attribute called 'textColorName' (or editing the
 * associated property exposed in the property inspector), setting its value to 'corporate'. If the color 
 * is defined on a UIColor subclass, say +[SomeColor corporateColor] color, then set the 'textColorName' 
 * value to 'SomeColor:corporate'
 */
+ (instancetype)colorWithName:(NSString *)name;

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

/**
 * User-defined runtime attributes exposed in the attributes inspector. Not meant to be set in code
 */
@interface UIView (HLSColorInspectables)

@property (nonatomic, readonly, assign) IBInspectable NSString *backgroundColorName;
@property (nonatomic, readonly, assign) IBInspectable NSString *tintColorName;

@end

@interface UILabel (HLSColorInspectables)

@property (nonatomic, readonly, assign) IBInspectable NSString *textColorName;
@property (nonatomic, readonly, assign) IBInspectable NSString *shadowColorName;
@property (nonatomic, readonly, assign) IBInspectable NSString *highlightedTextColorName;

@end

@interface UITextView (HLSColorInspectables)

@property (nonatomic, readonly, assign) IBInspectable NSString *textColorName;

@end

@interface UITextField (HLSColorInspectables)

@property (nonatomic, readonly, assign) IBInspectable NSString *textColorName;

@end

@interface UISearchBar (HLSColorInspectables)

@property (nonatomic, readonly, assign) IBInspectable NSString *barTintColorName;

@end

