//
//  HLSAutorotation.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

// Enum available starting with the iOS 6 SDK, here made available for previous SDK versions as well
typedef enum {
    UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
} UIInterfaceOrientationMask;

#endif

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
