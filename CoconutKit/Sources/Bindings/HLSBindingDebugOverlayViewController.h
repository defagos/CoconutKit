//
//  HLSBindingDebugOverlayViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSViewController.h"

/**
 * Overlay view controller displaying binding debug information
 */
@interface HLSBindingDebugOverlayViewController : HLSViewController <UIPopoverControllerDelegate>

/**
 * Show the overlay
 */
+ (void)showForDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive;

@end
