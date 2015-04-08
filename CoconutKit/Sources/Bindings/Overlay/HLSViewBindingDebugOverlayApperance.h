//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSNullability.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Appearance settings for binding debugging overlay buttons
 */
CGFloat HLSViewBindingDebugOverlayBorderWidth(BOOL isViewAutomaticallyUpdated);
UIColor *HLSViewBindingDebugOverlayBorderColor(BOOL isVerified, BOOL hasError);
UIColor *HLSViewBindingDebugOverlayBackgroundColor(BOOL isVerified, BOOL hasError, BOOL isModelAutomaticallyUpdated);

/**
 * Basic apperance settings for binding debugging overlay buttons
 */
UIImage *HLSViewBindingDebugOverlayStripesPatternImage(void);
CGFloat HLSViewBindingDebugOverlayAlpha(void);

NS_ASSUME_NONNULL_END
