//
//  CursorCustomPointerView.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorCustomPointerView.h"

@implementation CursorCustomPointerView

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.valueLabel = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize valueLabel = m_valueLabel;

@end
