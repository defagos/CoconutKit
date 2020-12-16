//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAutorotation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarController (HLSExtensions)

/**
 * Set how a tab bar controller decides whether it must rotate or not
 *
 * HLSAutorotationModeContainer: The original UIKit behavior is used
 * HLSAutorotationModeContainerAndNoChildren: No children decide whether rotation occur, and none receive the
 *                                            related events
 * HLSAutorotationModeContainerAndTopChildren
 * HLSAutorotationModeContainerAndAllChildren: The child view controllers decide whether rotation can occur, and receive
 *                                             the related events
 *
 * The default value is HLSAutorotationModeContainer
 */
@property (nonatomic) HLSAutorotationMode autorotationMode;

@end

NS_ASSUME_NONNULL_END
