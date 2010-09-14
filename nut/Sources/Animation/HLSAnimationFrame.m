//
//  HLSAnimationFrame.m
//  nut
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationFrame.h"

@implementation HLSAnimationFrame

#pragma mark Convenience methods

+ (HLSAnimationFrame *)animationFrame
{
    return [[[[self class] alloc] init] autorelease];
}

+ (HLSAnimationFrame *)animationFrameForView:(UIView *)view
{
    HLSAnimationFrame *animationFrame = [HLSAnimationFrame animationFrame];
    animationFrame.alpha = view.alpha;
    
    return animationFrame;
}

+ (HLSAnimationFrame *)animationFrameMovingView:(UIView *)view toFrame:(CGRect)frame
{
    // Convert rectangles into the window coordinate system
    CGRect beginFrameInWindow = [view.superview convertRect:view.frame toView:nil];
    CGRect endFrameInWindow = [view.superview convertRect:frame toView:nil];
    
    // Scaling matrix
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(endFrameInWindow.size.width / beginFrameInWindow.size.width, 
                                                                  endFrameInWindow.size.height / beginFrameInWindow.size.height);
    
    // Rect centers in the window coordinate system
    CGPoint beginCenterInWindow = CGPointMake(CGRectGetMidX(beginFrameInWindow), CGRectGetMidY(beginFrameInWindow));
    CGPoint endCenterInWindow = CGPointMake(CGRectGetMidX(endFrameInWindow), CGRectGetMidY(endFrameInWindow));
    
    // Translation matrix
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(endCenterInWindow.x - beginCenterInWindow.x, 
                                                                              endCenterInWindow.y - beginCenterInWindow.y);
    
    // Return the resulting animation frame
    HLSAnimationFrame *animationFrame = [HLSAnimationFrame animationFrame];
    animationFrame.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    
    return animationFrame;
}

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        // Default: No change
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1.f;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize transform = m_transform;

@synthesize alpha = m_alpha;

@end
