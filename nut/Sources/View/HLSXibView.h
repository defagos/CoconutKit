//
//  HLSXibView.h
//  nut
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Convenience factory macro for creating views of a given class; useful since no covariant return types in Objective-C
#define HLS_XIB_VIEW(className)                 (className *)[className xibView]

// Convenience macro for retrieving the height of a view
#define HLS_XIB_VIEW_HEIGHT(className)          [className height]

/**
 * Abstract class for easy view creation using xibs.
 *
 * Simply inherit from this class to define your custom view classes (this class is abstract and therefore not meant
 * to be instantiated directly). This forces you to define view properties in a standard and centralized way (namely 
 * in the implementation file of the corresponding class), instead of putting redundant code in all source files using
 * the view.
 *
 * To create your own view class, simply subclass HLSXibView. If your view layout is created using a xib file not 
 * bearing the same name as the view class, override the xibFileName accessor to return the name of the xib file. 
 * If the xib file bears the same name as its corresponding class, you do not need to override this accessor.
 * Your custom classes can then be instantiated using the provided factory macro.
 *
 * To define the view layout in Interface Builder, the first object in the xib must be the view object. Do not forget 
 * to set its type to match your view class name (if you need to bind outlets). Use this class as origin when drawing 
 * bindings (do not use the file's owner)
 *
 * Designated initializer: initWithFrame: (you usually do not need to create a view manually. Use the factory method 
 * instead)
 */
@interface HLSXibView : UIView {
@private
    
}

/**
 * Factory method for creating the view
 * Not meant to be overridden
 */
+ (UIView *)xibView;

/**
 * Return the height of the view.
 * Not meant to be overridden
 */
+ (CGFloat)height;

/**
 * If the view layout is created using Interface Builder, override this accessor to return the name of the associated xib
 * file. This is not needed if the xib file name is identical to the class name
 */
+ (NSString *)xibFileName;

@end
