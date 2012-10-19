//
//  HLSAutorotation.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAutorotation.h"

#import <objc/runtime.h>

HLSAutorotationMode HLSAutorotationModeDefault()
{
    static HLSAutorotationMode s_defaultAutorotationMode = 0;
    
    static BOOL s_initialized = NO;
    if (! s_initialized) {
        // iOS 6 and above
        if (class_getInstanceMethod([UIViewController class], @selector(shouldAutorotate))) {
            s_defaultAutorotationMode = HLSAutorotationModeContainer;
        }
        // < iOS 6
        else {
            s_defaultAutorotationMode = HLSAutorotationModeContainerAndVisibleChildren;
        }
    }
    return s_defaultAutorotationMode;
}
