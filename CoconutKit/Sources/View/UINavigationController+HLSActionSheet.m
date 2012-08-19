//
//  UINavigationController+HLSActionSheet.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 25.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UINavigationController+HLSActionSheet.h"

#import "HLSActionSheet+Friend.h"
#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static BOOL (*s_UINavigationController__navigationBar_shouldPopItem_Imp)(id, SEL, id, id) = NULL;

// Swizzled method implementations
static BOOL swizzled_UINavigationController__navigationBar_shouldPopItem_Imp(UINavigationController *self, SEL _cmd, UINavigationBar *navigationBar, UINavigationBar *item);

@implementation UINavigationController (HLSActionSheet)

+ (void)load
{
    s_UINavigationController__navigationBar_shouldPopItem_Imp = (BOOL (*)(id, SEL, id, id))HLSSwizzleSelector(self, 
                                                                                                              @selector(navigationBar:shouldPopItem:), 
                                                                                                              (IMP)swizzled_UINavigationController__navigationBar_shouldPopItem_Imp);
}

@end

#pragma mark Swizzled method implementations

static BOOL swizzled_UINavigationController__navigationBar_shouldPopItem_Imp(UINavigationController *self, SEL _cmd, UINavigationBar *navigationBar, UINavigationBar *item)
{
    if (! (*s_UINavigationController__navigationBar_shouldPopItem_Imp)(self, _cmd, navigationBar, item)) {
        return NO;
    }
    
    [HLSActionSheet dismissCurrentActionSheetAnimated:NO];
    return YES;
}
