//
//  HLSViewBindingDebugOverlayViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewController.h"

/**
 * Overlay view controller displaying binding debugging information
 */
@interface HLSViewBindingDebugOverlayViewController : HLSViewController <UIPopoverControllerDelegate>

/**
 * Show the overlay, displaying bound fields in the specified view controller. If recursive is set to YES, fields
 * located in child view controllers will be displayed as well
 */
+ (void)showForDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive;

@end

@interface HLSViewBindingDebugOverlayViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
