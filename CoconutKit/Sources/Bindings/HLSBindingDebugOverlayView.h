//
//  HLSBindingDebugOverlayView.h
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Overlay view to debug binding information
 */
@interface HLSBindingDebugOverlayView : UIView <UIPopoverControllerDelegate>

/**
 * Create the debug overlay, for displaying information regarding the specified view controller. If recursive is
 * set to YES, information for child view controllers is displayed as well, otherwise only information regarding
 * the specified view controller is displayed
 */
- (id)initWithDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive;

/**
 * Show the overlay
 */
- (void)show;

@end
