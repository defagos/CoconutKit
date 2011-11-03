//
//  UINavigationBar+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "UINavigationBar+HLSExtensions.h"

static const NSInteger kBackgroundImageViewTag = 7456;          // Hopefully not colliding with another tag :-)

@implementation UINavigationBar (HLSExtensions)

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
                backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                [self insertSubview:backgroundImageView atIndex:0];                
            }
        }
    }
}

@end
