//
//  UINavigationBar+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "UINavigationBar+HLSExtensions.h"

#import "HLSRuntime.h"
#import "UIView+HLSExtensions.h"

/**
 * As navigation levels are pushed onto the stack, the navigation bar is updated. During this process, and if we
 * do nothing, the background view gets on top of the title and button widgets, hiding them. To avoid this, we
 * ensure that any view hierarchy change leaves the background view at the bottom of the view hierarchy. This
 * is done by swizzling methods which can potentially put a view behind the background view
 *
 * This idea was borrowed from http://sebastiancelis.com/2009/12/21/adding-background-image-uinavigationbar/
 */

static const NSInteger kBackgroundImageViewTag = 7456;          // Hopefully not colliding with another tag :-)

// Original implementation of the methods we swizzle
static void (*s_UINavigationBar__insertSubview_atIndex_Imp)(id, SEL, id, NSInteger) = NULL;
static void (*s_UINavigationBar__insertSubview_belowSubview_Imp)(id, SEL, id, id) = NULL;
static void (*s_UINavigationBar__sendSubviewToBack_Imp)(id, SEL, id) = NULL;

// Swizzled method implementations
static void swizzled_UINavigationBar__insertSubview_atIndex_Imp(UINavigationBar *self, SEL _cmd, UIView *view, NSInteger index);
static void swizzled_UINavigationBar__insertSubview_belowSubview_Imp(UINavigationBar *self, SEL _cmd, UIView *view, UIView *siblingSubview);
static void swizzled_UINavigationBar__sendSubviewToBack_Imp(UINavigationBar *self, SEL _cmd, UIView *view);

@implementation UINavigationBar (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    s_UINavigationBar__insertSubview_atIndex_Imp = (void (*)(id, SEL, id, NSInteger))HLSSwizzleSelector(self, 
                                                                                                        @selector(insertSubview:atIndex:), 
                                                                                                        (IMP)swizzled_UINavigationBar__insertSubview_atIndex_Imp);
    s_UINavigationBar__insertSubview_belowSubview_Imp = (void (*)(id, SEL, id, id))HLSSwizzleSelector(self, 
                                                                                                      @selector(insertSubview:belowSubview:), 
                                                                                                      (IMP)swizzled_UINavigationBar__insertSubview_belowSubview_Imp);
    s_UINavigationBar__sendSubviewToBack_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, 
                                                                                         @selector(sendSubviewToBack:), 
                                                                                         (IMP)swizzled_UINavigationBar__sendSubviewToBack_Imp);
}

#pragma mark Accessors and mutators

@dynamic backgroundImage;

- (UIImage *)backgroundImage
{
    UIImageView *backgroundImageView = (UIImageView *)[self viewWithTag:kBackgroundImageViewTag];
    return backgroundImageView.image;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    // iOS 5 and above: Built-in support
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        return;
    }
    // Below iOS 5: Tweak view hierarchy
    else {    
        // Trick: The background view is identified using a tag
        UIImageView *backgroundImageView = (UIImageView *)[self viewWithTag:kBackgroundImageViewTag];
        
        // Already added
        if (backgroundImageView) {
            // Changing the existing image
            if (backgroundImage) {
                backgroundImageView.image = backgroundImage;
            }
            // Removing the image
            else {
                [backgroundImageView removeFromSuperview];
            }
        }
        // Adding
        else {
            if (backgroundImage) {
                UIImageView *backgroundImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
                backgroundImageView.image = backgroundImage;
                backgroundImageView.tag = kBackgroundImageViewTag;
                backgroundImageView.contentMode = UIViewContentModeScaleToFill;
                backgroundImageView.autoresizingMask = HLSViewAutoresizingAll;
                
                (*s_UINavigationBar__insertSubview_atIndex_Imp)(self, @selector(insertSubview:atIndex:), backgroundImageView, 0);
            }
        }
    }
}

@end

#pragma mark Swizzled method implementations

static void swizzled_UINavigationBar__insertSubview_atIndex_Imp(UINavigationBar *self, SEL _cmd, UIView *view, NSInteger index)
{
    (*s_UINavigationBar__insertSubview_atIndex_Imp)(self, _cmd, view, index);
    
    UIImageView *backgroundImageView = (UIImageView *)[self viewWithTag:kBackgroundImageViewTag];
    if (backgroundImageView) {
        (*s_UINavigationBar__sendSubviewToBack_Imp)(self, @selector(sendSubviewToBack:), backgroundImageView);
    }
}

static void swizzled_UINavigationBar__insertSubview_belowSubview_Imp(UINavigationBar *self, SEL _cmd, UIView *view, UIView *siblingSubview)
{
    (*s_UINavigationBar__insertSubview_belowSubview_Imp)(self, _cmd, view, siblingSubview);
    
    UIImageView *backgroundImageView = (UIImageView *)[self viewWithTag:kBackgroundImageViewTag];
    if (backgroundImageView) {
        (*s_UINavigationBar__sendSubviewToBack_Imp)(self, @selector(sendSubviewToBack:), backgroundImageView);
    }
}

static void swizzled_UINavigationBar__sendSubviewToBack_Imp(UINavigationBar *self, SEL _cmd, UIView *view)
{
    (*s_UINavigationBar__sendSubviewToBack_Imp)(self, _cmd, view);
    
    UIImageView *backgroundImageView = (UIImageView *)[self viewWithTag:kBackgroundImageViewTag];
    if (backgroundImageView) {
        (*s_UINavigationBar__sendSubviewToBack_Imp)(self, @selector(sendSubviewToBack:), backgroundImageView);
    }
}
