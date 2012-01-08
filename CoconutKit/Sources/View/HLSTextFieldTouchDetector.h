//
//  HLSTextFieldTouchDetector.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSTextFieldInternalDelegate.h"

/**
 * Private class for implementation purposes. This internal delegate traps when a text field enters or exits
 * edit mode, enabling tap detection during edit mode. This allows us to dismiss the keyboard if the user
 * taps outside a text field when it is in edit mode.
 *
 * Designated initializer: initWithTextField:
 */
@interface HLSTextFieldTouchDetector : HLSTextFieldInternalDelegate {
@private
    UIGestureRecognizer *m_gestureRecognizer;
}

@end
