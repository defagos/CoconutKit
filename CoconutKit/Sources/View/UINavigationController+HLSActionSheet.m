//
//  UINavigationController+HLSActionSheet.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 25.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UINavigationController+HLSActionSheet.h"

#import "HLSActionSheet+Friend.h"
#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"

HLSLinkCategory(UINavigationController_HLSActionSheet)

// Original implementations of the methods we swizzle
static BOOL (*s_UINavigationController__swizzledNavigationBar_shouldPopItem_Imp)(id, SEL, id, id) = NULL;

@implementation UINavigationController (HLSActionSheet)

+ (void)load
{
    s_UINavigationController__swizzledNavigationBar_shouldPopItem_Imp = (BOOL (*)(id, SEL, id, id))HLSSwizzleSelector(self, 
                                                                                                                      @selector(navigationBar:shouldPopItem:), 
                                                                                                                      @selector(swizzledNavigationBar:shouldPopItem:));
}

- (BOOL)swizzledNavigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if (! (*s_UINavigationController__swizzledNavigationBar_shouldPopItem_Imp)(self, @selector(navigationBar:shouldPopItem:), navigationBar, item)) {
        return NO;
    }
    
    [HLSActionSheet dismissCurrentActionSheetAnimated:NO];
    return YES;
}

@end
