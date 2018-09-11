//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Overlay view controller displaying binding debugging information
 */
@interface HLSViewBindingDebugOverlayViewController : HLSViewController

/**
 * Show an overlay displaying bound fields in the current key window
 */
+ (void)show;

/**
 * Return the current overlay, nil if none
 */
+ (nullable HLSViewBindingDebugOverlayViewController *)currentBindingDebugOverlayViewController;

/**
 * Animate a frame to highlight a given view on the overlay
 */
- (void)highlightView:(UIView *)view;

@end

@interface HLSViewBindingDebugOverlayViewController (UnavailableMethods)

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(nullable NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
