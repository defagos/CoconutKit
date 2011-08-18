//
//  CursorPointerInfoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 21.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorPointerInfoViewController.h"

@implementation CursorPointerInfoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.valueLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize valueLabel = m_valueLabel;

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Localization

- (void)localize
{
}

@end
