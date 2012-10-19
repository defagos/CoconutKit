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
    HLSInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    HLSInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    HLSInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
} HLSInterfaceOrientationMask;

/**
 * Set up how a container behaves when interface rotation occurs
 */
typedef enum {
    HLSAutorotationModeEnumBegin = 0,
    HLSAutorotationModeContainer = HLSAutorotationModeEnumBegin,            // The container itself decides whether rotation can occur or not
    HLSAutorotationModeContainerAndVisibleChildren,                         // The container and its visible children decide whether rotation can occur or not
    HLSAutorotationModeContainerAndChildren,                                // The container and all its children (even not visible) decide whether rotation can occur or not
    HLSAutorotationModeEnumEnd,
    HLSAutorotationModeEnumSize = HLSAutorotationModeEnumEnd - HLSAutorotationModeEnumBegin
} HLSAutorotationMode;

/**
 * The default orientation mode applied by containers:
 *   - iOS 4 and 5: HLSAutorotationModeContainerAndVisibleChildren
 *   - iOS 6: HLSAutorotationModeContainer
 */
HLSAutorotationMode HLSAutorotationModeDefault();
