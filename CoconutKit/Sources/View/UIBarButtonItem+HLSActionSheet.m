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
    // Remark: [HLSActionSheet dismissCurrentActionSheetAnimated:YES] cannot be factored out
    //         below. It namely changes the result of [HLSActionSheet currentActionSheet], the
    //         order is therefore especially important here
    
    // Clicking on a bar button item different than the one from which the action sheet is
    // shown. Dismiss current action sheet and trigger button action
    if ([HLSActionSheet currentActionSheet].owner != (id)self) {
        [HLSActionSheet dismissCurrentActionSheetAnimated:YES];
        
        // Support both selectors of the form - (void)action:(id)sender and - (void)action
        SEL action = (*s_UIBarButtonItem__action_Imp)(self, @selector(action));
        id target = (*s_UIBarButtonItem__target_Imp)(self, @selector(target));
        [target performSelector:action withObject:sender];
    }
    // Clicking on the same bar button item from which the action sheet was shown. Close it
    // but do not trigger the button action again
    else {
        [HLSActionSheet dismissCurrentActionSheetAnimated:YES];
    }
}

@end
