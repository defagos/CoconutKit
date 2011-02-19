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
 * the scroll view is automatically moved so that the field remains visible when the keyboard is displayed.
 * To create forms easily, it therefore suffices to start with a scroll view (even for small views where scrolling 
 * is not required) and to add HLSTextFields somewhere down its view hierarchy (usually as direct children).
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSTextField : UITextField {
@private

}

@end
