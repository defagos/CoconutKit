//
//  HLSAutorotation.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Enum equivalent to the UIInterfaceOrientationMask enum available starting with the iOS 6 SDK. Use these values
 * if you plan to compile your project against an older version of the SDK only
 */
typedef enum {
    HLSInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    HLSInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    HLSInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    HLSInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    HLSInterfaceOrientationMaskLandscape = (HLSInterfaceOrientationMaskLandscapeLeft | HLSInterfaceOrientationMaskLandscapeRight),
    HLSInterfaceOrientationMaskAll = (HLSInterfaceOrientationMaskPortrait | HLSInterfaceOrientationMaskLandscapeLeft | HLSInterfaceOrientationMaskLandscapeRight | HLSInterfaceOrientationMaskPortraitUpsideDown),
    HLSInterfaceOrientationMaskAllButUpsideDown = (HLSInterfaceOrientationMaskPortrait | HLSInterfaceOrientationMaskLandscapeLeft | HLSInterfaceOrientationMaskLandscapeRight),
} HLSInterfaceOrientationMask;

/**
 * Set up how a container view controller behaves when interface rotation occurs. This means:
 *   - which view controllers decide whether rotation can occur
 *   - which view controllers receive rotation events (for children, from the topmost to the bottommost view controller)
 * THe default values are currently:
 *   - for iOS 4 and 5: HLSAutorotationModeContainerAndVisibleChildren
 *   - for iOS 6: HLSAutorotationModeContainer
 */
typedef enum {
    HLSAutorotationModeEnumBegin = 0,
    HLSAutorotationModeContainer = HLSAutorotationModeEnumBegin,            // Default: The container decides (it might consider children on not depending on iOS versions)
    HLSAutorotationModeContainerAndVisibleChildren,                         // The container and its visible children are involved
    HLSAutorotationModeContainerAndChildren,                                // The container and all its children (even not visible) are involved
    HLSAutorotationModeEnumEnd,
    HLSAutorotationModeEnumSize = HLSAutorotationModeEnumEnd - HLSAutorotationModeEnumBegin
} HLSAutorotationMode;
