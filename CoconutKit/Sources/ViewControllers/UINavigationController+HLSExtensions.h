//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAutorotation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (HLSExtensions)

/**
 * Set how a navigation controller decides whether it must rotate or not
 *
 * HLSAutorotationModeContainer: The original UIKit behavior is used
 * HLSAutorotationModeContainerAndNoChildren: No children decide whether rotation occur, and none receive the
 *                                            related events
 * HLSAutorotationModeContainerAndTopChildren: The top child view controller decide whether rotation can occur,
 *                                             and receive the related events
 * HLSAutorotationModeContainerAndAllChildren: All child view controllers decide whether rotation can occur, and receive
 *                                             the related events
 *
 * The default value is HLSAutorotationModeContainer
 */
@property (nonatomic) HLSAutorotationMode autorotationMode;

/**
 * Set to YES to automatically forward the status bar style decision to the top view controller
 *
 * The default value is NO (standard UINavigationController behavior)
 */
@property (nonatomic, getter=isForwardingStatusBarStyle) BOOL forwardingStatusBarStyle;

@end

NS_ASSUME_NONNULL_END
