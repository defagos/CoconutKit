//
//  HLSNibView.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Abstract class for easy view creation using xibs.
 *
 * Simply inherit from this class to define your custom view classes (this class is abstract and therefore not meant
 * to be instantiated directly). This forces you to define view properties in a standard and centralized way (namely 
 * in the implementation file of the corresponding class), instead of putting redundant code in all source files using
 * the view.
 *
 * To create your own view class, simply subclass HLSNibView. If your view layout is created using a xib file not 
 * bearing the same name as the view class, override the nibName accessor to return the name of the xib file. 
 * If the xib file bears the same name as its corresponding class, you do not need to override this accessor.
 * Your custom classes can then be instantiated using the view class method.
 *
 * To define the view layout in Interface Builder, the first object in the xib must be the view object. Do not forget 
 * to set its type to match your view class name (if you need to bind outlets). Use this class as origin when drawing 
 * bindings (do not use the file's owner)
 *
 * Designated initializer: initWithFrame: (you usually do not need to create a view manually. Use the factory method 
 * instead)
 */
@interface HLSNibView : UIView {
@private
    
}

/**
 * Factory method for creating the view. Return an instance of the class it is called on
 * Not meant to be overridden
 */
+ (id)view;

/**
 * Return the view dimensions
 * Not meant to be overridden
 */
+ (CGFloat)height;
+ (CGFloat)width;
+ (CGSize)size;

/**
 * If the view layout is created using Interface Builder, override this accessor to return the name of the associated xib
 * file. This is not needed if the xib file name is identical to the class name
 */
+ (NSString *)nibName;

@end
