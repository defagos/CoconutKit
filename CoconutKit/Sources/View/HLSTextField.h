//
//  HLSTextField.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/12/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Forward declarations
@class HLSTextFieldTouchDetector;

/**
 * Thin wrapper to UITextField adding standard useful functionality.
 *
 * Most notably, when wrapped within a scroll view (either as direct parent view or higher in the view hierarchy),
 * the scroll view is automatically applied an offset so that the field stays completely visible (vertically) when 
 * the keyboard is displayed. When exiting input mode, the original scroll view offset is restored. Moreover, such
 * text fields allow the user to exit edit mode by tapping outside the text field (this behavior is enabled by
 * default).
 *
 * Using HLSTextField, creating forms is very easy: You usually start with a scroll view (even if the form fits 
 * on a single screen), then you add HLSTextFields to it, usually as direct children.
 *
 * Complex scroll view hierarchies are also supported. You can e.g. embbed a scroll view containing HLSTextField 
 * objects within other scroll views at will. When a text field needs to be displayed, it is always the bottommost
 * scroll view which is applied an offset if needed. Always remember this fact when designing your forms.
 *
 * At most one scroll view is applied an offset at any time. If a form contains two separate scroll views having
 * no common scroll view in their parent view hierarchy (each with their own set of HLSTextFields), their motion
 * will be decoupled when offsets are applied, which is not really attractive. In such cases, always remember that 
 * you can add a common scroll view parent to a set of disjoint scroll views in order to keep their vertical
 * motion synchronized.
 *
 * There is only a small issue with scroll views expanding in the horizontal direction (quite rare for forms,
 * which usually expand vertically): For such scroll views, a built-in UIKit behavior automatically adjusts the 
 * horizontal offset of a scroll view so that a text field contained within it stays completely visible when active. 
 * This animated effect interferes with the vertical offsets apply by HLSTextField (even if not animated). The 
 * behavior of HLSTextField objects remains correct, but the offset animations suffer from "hiccups" because of 
 * the two effects overlapping. Since such views should be quite rare, though, this issue should not be a severe one.
 *
 * If you need to subclass HLSTextField (which should be quite rare), do not forget to implement awakeFromNib,
 * calling the super method first (otherwise the behavior of HLSTextFields instantiated from a xib will be
 * undefined)
 *
 * TODO: We could add a button above the keyboard (or somewhere else) to allow fast switching between HLSTextFields 
 *       without having to hide the keyboard. A better approach would allow fast switching between UIResponders (e.g. 
 *       a picker view, a text field, etc.)
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSTextField : UITextField {
@private
    HLSTextFieldTouchDetector *m_touchDetector;
    CGFloat m_minVisibilityDistance;
}

/**
 * Minimal (positive) distance to keep between keyboard and text field, respectively scroll view top and text field
 * Default value is 20.f
 */
@property (nonatomic, assign) CGFloat minVisibilityDistance;

/**
 * If set to YES, the text field relinquishes its first responder status (if it is the first responder)
 * Default value is YES
 */
@property (nonatomic, assign) BOOL resigningFirstResponderOnTap;

@end
