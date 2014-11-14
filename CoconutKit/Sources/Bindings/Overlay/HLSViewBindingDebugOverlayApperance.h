//
//  HLSViewBindingDebugOverlayApperance.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//


CGFloat HLSViewBindingDebugOverlayBorderWidth(BOOL updatedAutomatically);
UIColor *HLSViewBindingDebugOverlayBorderColor(BOOL isVerified, BOOL hasError);
UIColor *HLSViewBindingDebugOverlayBackgroundColor(BOOL isVerified, BOOL hasError, BOOL supportsInput);

UIImage *HLSViewBindingDebugOverlayStripesPatternImage(void);
CGFloat HLSViewBindingDebugOverlayAlpha(void);
