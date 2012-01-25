//
//  HLSActionSheet.h
//  CoconutKit
//
//  Created by Samuel Défago on 24.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * The built-in UIActionSheet is rather inconvenient when action buttons are enabled or not depending on
 * some context. Imagine for example a menu letting you take a picture using the camera, or choose one
 * from your library. If either one is unavailable for some reason, the corresponding option should not
 * be displayed in the menu. In such cases it is rather inconvenient for the delegate to implement the 
 * actionSheet:clickedButtonAtIndex: protocol method, since the index it receives does not always correspond 
 * to the same action depending on which actions buttons were actually available.
 *
 * Moreover, UIActionSheet has a strange behavior on the iPad: When an action sheet is shown, it usually 
 * can be dismissed when the user taps outside it. The only exception is when the action sheet is shown
 * from a bar button item: In such cases, all toolbar buttons (in the same toolbar) remain active, including 
 * of course the one which shows the action sheet. Tapping outside an action sheet therefore does not 
 * dismiss it if the tap occurs in the same toolbar which the button showing it belongs to. In such cases, 
 * additional code has to be written by clients so that the behavior stays correct, which means:
 *   - avoiding the user to be able to stack up action sheets by repeatedly tapping the same bar button item
 *   - tapping a bar button while another one is displaying an action sheet must dismiss the action sheet
 *   - dismissing the action sheet when navigating back in a navigation controller
 *
 * The HLSActionSheet class solves all the above issues. When creating an action sheet, you add buttons to
 * it, attaching targets and actions as you would for a button. This makes it easy to keep your code well 
 * organized. Moreover, correct behavior with bar buttons is ensured.
 * 
 * To create and display an HLSActionSheet object, proceed as follows:
 *   - initialize the object using the init method (the designated intializer inherited from
 *     UIActionSheet cannot be used anymore)
 *   - further customize the action sheet using the properties inherited from UIActionSheet (if
 *     needed). The destructiveButtonIndex and cancelButtonIndex properties have been overridden
 *     and do nothing anymore
 *   - add the buttons in the order you want them displayed on screen, using the add... methods
 * Then display the HLSActionSheet using the show... methods inherited from UIActionSheet.
 *
 * Wherever you used a UIActionSheet, you can replace it with an HLSActionSheet with little effort.
 * HLSActionSheet is not strictly a drop-in replacement for UIActionSheet, but almost. In general,
 * all you have to do is replacing the 
 *     initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:
 * call used to initialize a UIActionSheet with a call to init, followed by calls to the three
 * add methods of HLSActionSheet.
 *
 * Remarks:
 *   - You can still have a delegate if you want. It will catch the exact same events as if you had used
 *     a built-in UIActionSheet. This is useful for menus letting you choose a value from a set of elements
 *     (e.g. a set of languages given by the system)
 *   - iPad: If you tap outside the pop-up, the protocol methods
 *        actionSheet:clickedButtonAtIndex:
 *        actionSheet:willDismissWithButtonIndex:
 *        actionSheet:didDismissWithButtonIndex:
 *     are called, each one receiving -1 as button index. This is the same as for UIActionSheet, but I
 *     found it useful to have it documented somewhere.
 *
 * Designated initializer: init
 */
@interface HLSActionSheet : UIActionSheet {
@private
    NSArray *m_targets;
    NSArray *m_actions;
    id<UIActionSheetDelegate> m_realDelegate;
}

/**
 * Add a standard button at the end of the current button list, with a specific target and action.
 * The index of the added button is returned.
 * Only one such button can be added, the function returns the index of the existing one if called
 * more than once.
 *
 * The signature of action must be - (void)methodName:(id)sender (sender is the action sheet)
 * or - (void)methodName
 *
 * This method does nothing on the iPad
 */
- (NSInteger)addCancelButtonWithTitle:(NSString *)cancelButtonTitle 
                               target:(id)target
                               action:(SEL)action;

/**
 * Add a destructive button at the end of the current button list, with a specific target and action.
 * The index of the added button is returned.
 * Only one such button can be added, the function returns the index of the existing one if called
 * more than once.
 *
 * The signature of action must be - (void)methodName:(id)sender (sender is the action sheet)
 * or - (void)methodName
 */
- (NSInteger)addDestructiveButtonWithTitle:(NSString *)destructiveButtonTitle 
                                    target:(id)target
                                    action:(SEL)action;

/**
 * Add a standard button at the end of the current button list, with a specific target and action.
 * The index of the added button is returned.
 *
 * The signature of action must be - (void)methodName:(id)sender (sender is the action sheet)
 * or - (void)methodName
 */
- (NSInteger)addButtonWithTitle:(NSString *)title
                         target:(id)target
                         action:(SEL)action;

@end
