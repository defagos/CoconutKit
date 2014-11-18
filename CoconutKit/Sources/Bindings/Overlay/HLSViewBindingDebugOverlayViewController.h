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
 * Show an overlay displaying bound fields in the current key window
 */
+ (void)show;

/**
 * Return the current overlay, nil if none
 */
+ (HLSViewBindingDebugOverlayViewController *)currentBindingDebugOverlayViewController;

/**
 * Animate a frame to highlight a given view on the overlay
 */
- (void)highlightView:(UIView *)view;

@end

@interface HLSViewBindingDebugOverlayViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
