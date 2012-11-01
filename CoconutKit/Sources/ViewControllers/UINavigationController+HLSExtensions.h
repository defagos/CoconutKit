//
//  UINavigationController+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAutorotation.h"

@interface UINavigationController (HLSExtensions)

/**
 * Set how a navigation controller decides whether it must rotate or not
 *
 * HLSAutorotationModeContainer: The original UIKit behavior is used (the top view controller decide on iOS 4 and 5,
 *                               none on iOS 6)
 * HLSAutorotationModeContainerAndNoChildren: No children decide whether rotation occur, and none receive the
 *                                            related events
 * HLSAutorotationModeContainerAndTopChildren: The top child view controller decide whether rotation can occur,
 *                                             and receive the related events
 * HLSAutorotationModeContainerAndAllChildren: All child view controllers decide whether rotation can occur, and receive
 *                                             the related events
 *
 * The default value is HLSAutorotationModeContainer
 */
@property (nonatomic, assign) HLSAutorotationMode autorotationMode;

@end
