//
//  HLSTextField.h
//  nut
//
//  Created by Samuel Défago on 10/12/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Thin wrapper to UITextField adding standard useful functionality.
 *
 * Most notably, when wrapped within a scroll view (either as direct parent view or higher in the view hierarchy),
 * the scroll view is automatically moved so that the field is completely visible when the keyboard is displayed.
 * To create forms easily, it therefore suffices to start with a scroll view (even for small views where scrolling 
 * is not required) and to add HLSTextFields somewhere down its view hierarchy (usually as direct children).
 *
 * There is a known minor issue with the iOS simulator: If the user uses the tab key to switch between fields
 * too fast, then the scroll view might not return back to its original position when the keyboard is dismissed.
 * This is due to the fact that the scroll offset update is animated, and animations can overlap since it is
 * difficult to hook a delegate in the animation process (and the current implementation is complicated
 * enough for the moment). The simplest way to solve this issue would have been to remove the animations, but 
 * they help the user to understand where the focus is moving.
 *
 * There is also another issue with scroll views expanding in the horizontal direction: For such scroll views,
 * a built-in UIKit behavior automatically animates text fields horizontally if they are not completely visible.
 * This effect interferes with the vertical offsets we apply (even if not animated). But since such views should
 * be quite rare, this issue should not be a severe one.
 *
 * TODO: We could add a button above the keyboard to allow fast switching between HLSTextFields without having
 *       to hide the keyboard. This would make filling forms from top to bottom very convenient, but would 
 *       require us to fix the issue described above for the iOS simulator.
 *
 * Designated initializer: initWithFrame:
 */@interface HLSTextField : UITextField {
@private

}

@end
