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

@interface HLSBindingDebugOverlayViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
