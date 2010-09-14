//
//  HLSStandardView.h
//  FIVB
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Convenience macro for creating views of a given class
#define STANDARD_VIEW(className)                 (className *)[className view]

// Convenience macro for retrieving the height of a view
#define STANDARD_VIEW_HEIGHT(className)          [className height]

/**
 * "Pure virtual" methods
 */
@protocol HLSStandardViewAbstract

@optional
/**
 * Implement this method to reflect the height of the view in your nib file
 */
+ (CGFloat)height;

@end

/**
 * To make working with views generated using a nib (one example is table view headers), just inherit from this class. 
 * This forces you to define view properties in a standard and centralized way (namely in the implementation file
 * of the corresponding class), instead of putting redundant code in all code using the view.
 *
 * Use the factory method for creating a view in a standard way as well. The view object must be the first in your 
 * nib file, which must bear the same name as your view class.
 *
 * Designated initializer: initWithFrame: (you usually do not need to create a view manually. Use the factory method 
 * instead)
 */
@interface HLSStandardView : UIView <HLSStandardViewAbstract> {
@private
    
}

/**
 * Factory method for creating the view
 */
+ (UIView *)view;

@end
