//
//  HLSViewBindingDebugOverlayApperance.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

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
