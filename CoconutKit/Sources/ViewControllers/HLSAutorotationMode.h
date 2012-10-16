//
//  HLSAutorotationMode.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

typedef enum {
    HLSInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    HLSInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    HLSInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    HLSInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    HLSInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    HLSInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    HLSInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
} HLSInterfaceOrientationMask;

typedef enum {
    HLSAutorotationModeEnumBegin = 0,
    HLSAutorotationModeContainer = HLSAutorotationModeEnumBegin,
    HLSAutorotationModeContainerAndVisibleChildren,
    HLSAutorotationModeContainerAndChildren,
    HLSAutorotationModeEnumEnd,
    HLSAutorotationModeEnumSize = HLSAutorotationModeEnumEnd - HLSAutorotationModeEnumBegin
} HLSAutorotationMode;
