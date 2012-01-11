//
//  UINavigationBar+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface UINavigationBar (HLSExtensions)

/**
 * Set / retrieve the background image for the navigation bar. On iOS 5 you should use setBackgroundImage:forBarMetrics:
 */
@property (nonatomic, retain) UIImage *backgroundImage __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_5_0);

@end
