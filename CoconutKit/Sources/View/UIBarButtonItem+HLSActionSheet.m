//
//  UIBarButtonItem+HLSActionSheet.m
//  CoconutKit
//
//  Created by Samuel Défago on 23.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIBarButtonItem+HLSActionSheet.h"

#import "HLSActionSheet+Friend.h"
#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"
#import "UIActionSheet+HLSExtensions.h"

HLSLinkCategory(UIBarButtonItem_HLSActionSheet)

// Original implementations of the methods we swizzle
static SEL (*s_UIBarButtonItem__action_Imp)(id, SEL) = NULL;
static id (*s_UIBarButtonItem__target_Imp)(id, SEL) = NULL;

@implementation UIBarButtonItem (HLSActionSheet)

+ (void)load
{
    s_UIBarButtonItem__action_Imp = (SEL (*)(id, SEL))HLSSwizzleSelector(self, @selector(action), @selector(swizzledAction));
    s_UIBarButtonItem__target_Imp = (id (*)(id, SEL))HLSSwizzleSelector(self, @selector(target), @selector(swizzledTarget));
}

- (SEL)swizzledAction
{
    if ([HLSActionSheet currentActionSheet]) {
        return @selector(dismissCurrentActionSheetAndForward:);
    }
    else {
        return (*s_UIBarButtonItem__action_Imp)(self, @selector(action));
    }
}

- (id)swizzledTarget
{
    if ([HLSActionSheet currentActionSheet]) {
        return self;
    }
    else {
        return (*s_UIBarButtonItem__target_Imp)(self, @selector(target));
    }
}

- (void)dismissCurrentActionSheetAndForward:(id)sender
{
    // Warning: Cannot factor out [HLSActionSheet dismissCurrentActionSheet] since the result of [HLSActionSheet barButtonItemOwner]
    //          depends on it!
    if ([HLSActionSheet currentActionSheet].owner != (UIView *)self) {
        [HLSActionSheet dismissCurrentActionSheetAnimated:YES];
        
        // Support both selectors of the form - (void)action:(id)sender and - (void)action
        [self.target performSelector:self.action withObject:sender];
    }
    else {
        [HLSActionSheet dismissCurrentActionSheetAnimated:YES];
    }
}

@end
