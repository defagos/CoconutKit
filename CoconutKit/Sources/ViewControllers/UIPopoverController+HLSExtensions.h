//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (UIPopoverController_HLSExtensions)

/**
 * Return the popover controller which displays the receiver, or nil if none
 */
@property (nonatomic, readonly, weak) UIPopoverController *popoverController;

@end
