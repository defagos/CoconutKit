//
//  HLSNibView.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

/**
 * Abstract class for easy view creation using nibs.
 *
 * Simply inherit from this class to define your custom view classes (this class is abstract and therefore not meant
 * to be instantiated directly). This forces you to define view properties in a standard and centralized way (namely 
 * in the implementation file of the corresponding class), instead of putting redundant code in all source files using
 * the view.
 *
 * To create your own view class, simply subclass HLSNibView. If your view layout is created using a nib file not
 * bearing the same name as the view class, override the -nibName accessor to return the name of the nib file.
 * If the nib file bears the same name as its corresponding class, you do not need to override this accessor.
 * Your custom classes can then be instantiated using the +view class method. By default, the nib is searched
 * in the main bundle. If your nib is located in another bundle, override the +bundle method
 *
 * To define the view layout in Interface Builder, the first object in the nib must be the view object. Do not forget
 * to set its type to match your view class name (if you need to bind outlets). Use this class as origin when drawing 
 * bindings (do not use the file's owner)
 *
 * When adding an HLSNibView to a view hierarchy, you have two options:
 *   - In code: Instantiate the view programmatically and install it in the hierarchy
 *   - In Interface Builder: Add a placeholder view (a simple view containing no subviews) to a view, and set its class to
 *                           the HLSNibView to instantiate. An HLSNibView instance will automatically be added
 *                           within the placeholder view when the nib is deserialized (with same size and appropriate 
 *                           resizing behavior). If your placeholder view contains subviews, the result is undefined
 *                           (most likely a crash because of missing outlets)
 *
 * Designated initializer: -initWithFrame: (you usually do not need to create a view manually. Use the factory method 
 *                                          instead)
 */
@interface HLSNibView : UIView

/**
 * Factory method for creating the view. Return an instance of the class it is called on
 * Not meant to be overridden
 */
+ (instancetype)view;

/**
 * Return the view dimensions
 * Not meant to be overridden
 */
+ (CGFloat)height;
+ (CGFloat)width;
+ (CGSize)size;

/**
 * Override this accessor to return the name of the associated nib file. This is not needed if the nib file name is
 * identical to the class name
 */
+ (NSString *)nibName;

/**
 * If the nib is not located in the main bundle, override this method to return the bundle to search in (by
 * default, this method returns nil, which corresponds to the main bundle)
 */
+ (NSBundle *)bundle;

@end

// Can be overridden in subclasses but not intended to be called directly
@interface HLSNibView (UnavailableMethods)

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE NS_REQUIRES_SUPER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE NS_REQUIRES_SUPER;

@end

@interface HLSNibView (RequiresSuper)

- (void)awakeFromNib NS_REQUIRES_SUPER;

@end
