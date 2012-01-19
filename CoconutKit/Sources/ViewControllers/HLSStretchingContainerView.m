//
//  HLSStretchingContainerView.m
//  CoconutKit
//
//  Created by Samuel Défago on 21.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStretchingContainerView.h"

@implementation HLSStretchingContainerView

#pragma mark Object creation and destruction

- (id)init
{
    return [self initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

#pragma mark View events

- (void)willMoveToSuperview:(UIView *)superview
{
    [super willMoveToSuperview:superview];
    
    // Added to a window. Take all space available
    if ([superview isKindOfClass:[UIWindow class]]) {
        self.frame = [[UIScreen mainScreen] applicationFrame];
    }
    // Added to a view. Fit the parent frame size
    else if (superview) {
        self.frame = superview.bounds;
    }
}

@end
